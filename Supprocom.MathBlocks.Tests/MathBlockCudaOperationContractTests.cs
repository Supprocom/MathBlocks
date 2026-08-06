using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockCudaOperationContractTests
{
    [Fact]
    public void CUDA_operation_contract_covers_the_complete_catalog_and_slot_ABI()
    {
        var expectedIdentities = MathBlockCatalog.Standard.Operations
            .Select(operation => operation.Identity)
            .OrderBy(identity => identity, StringComparer.Ordinal)
            .ToArray();
        var contracts = MathBlockCudaDeviceModule.Operations;

        Assert.Equal(337, contracts.Count);
        Assert.Equal(expectedIdentities, contracts.Select(contract => contract.Identity));
        Assert.Equal(337, contracts.Select(contract => (contract.Family, contract.Opcode)).Distinct().Count());
        Assert.Equal(
            Enum.GetValues<MathBlockCudaOperationFamily>().OrderBy(value => value),
            contracts.Select(contract => contract.Family).Distinct().OrderBy(value => value));
        Assert.Equal(MathBlockCudaSlotLayout.Size, Marshal.SizeOf<MathBlockCudaSlotDescriptor>());
        Assert.Equal(
            MathBlockCudaSlotLayout.ScalarValueOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.ScalarValue)).ToInt32());
        Assert.Equal(
            MathBlockCudaSlotLayout.DataPointerOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.DataPointer)).ToInt32());
        Assert.Equal(
            MathBlockCudaSlotLayout.ScratchPointerOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.ScratchPointer)).ToInt32());
        Assert.Equal(
            MathBlockCudaSlotLayout.BooleanValueOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.BooleanValue)).ToInt32());
        Assert.Equal(
            MathBlockCudaSlotLayout.ValidOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Valid)).ToInt32());
        Assert.Equal(
            MathBlockCudaSlotLayout.RowsOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Rows)).ToInt32());
        Assert.Equal(
            MathBlockCudaSlotLayout.ColumnsOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Columns)).ToInt32());
        Assert.Equal(
            MathBlockCudaSlotLayout.CountOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Count)).ToInt32());
        Assert.Equal(
            MathBlockCudaSlotLayout.CapacityOffset,
            Marshal.OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Capacity)).ToInt32());

        foreach (var contract in contracts)
        {
            Assert.Equal(MathBlockCudaDeviceModule.DispatcherBlockSize, contract.RequiredBlockSize);
            Assert.True(contract.NativeBlockSize is 1u or 128u);
            Assert.Equal(64, contract.Fingerprint.Length);
            Assert.NotEmpty(contract.OperandTypeRule);
            Assert.NotEmpty(contract.OutputTypeRule);
            Assert.NotEmpty(contract.UnitRule);
            Assert.NotEmpty(contract.ShapeRule);
            Assert.NotEmpty(contract.CapacityRule);
            Assert.NotEmpty(contract.ScratchRule);
            Assert.NotEmpty(contract.ValidityRule);
            Assert.NotEmpty(contract.ExecutionRule);

            var contractCases = contract.GetContractCases();
            Assert.Equal(contract.RegressionCases.Count, contractCases.Count);
            for (var caseIndex = 0; caseIndex < contractCases.Count; caseIndex++)
            {
                var regression = contract.RegressionCases[caseIndex];
                var contractCase = contractCases[caseIndex];
                Assert.Equal(regression.Name, contractCase.Name);
                Assert.Equal(64, contractCase.EvidenceFingerprint.Length);
                Assert.Equal(regression.Inputs.Select(input => input.Type), contractCase.OperandTypes);
                Assert.True(
                    contractCase.Plan.OutputType.Accepts(regression.Expected.Type),
                    $"{contract.Identity}/{regression.Name}: planned {contractCase.Plan.OutputType}, expected {regression.Expected.Type}.");
                Assert.True(
                    contractCase.Plan.OutputCapacity >= PayloadCount(regression.Expected),
                    $"{contract.Identity}/{regression.Name}: planned capacity {contractCase.Plan.OutputCapacity}.");
                var actual = contract.EvaluateCPU(regression.Inputs);
                Assert.True(
                    actual.ApproximatelyEquals(regression.Expected, regression.Tolerance),
                    $"{contract.Identity}/{regression.Name}: CPU contract result differs.");
            }
        }
    }

    [Fact]
    public void CUDA_device_module_compiles_a_consumer_owned_nested_kernel()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var add = MathBlockCudaDeviceModule.GetOperation("scalar.add@1");
        var multiply = MathBlockCudaDeviceModule.GetOperation("scalar.multiply@1");
        var source = $$"""
            extern "C" __global__ void external_nested_formula(MathBlockSlot* slots)
            {
                if (blockIdx.x != 0)
                    return;
                const MathBlockSlot* add_inputs[2] = { &slots[0], &slots[1] };
                mathblocks_operation_dispatch(
                    {{(int)add.Family}}, {{add.Opcode}}, add_inputs, 2, &slots[2]);
                const MathBlockSlot* multiply_inputs[2] = { &slots[2], &slots[3] };
                mathblocks_operation_dispatch(
                    {{(int)multiply.Family}}, {{multiply.Opcode}}, multiply_inputs, 2, &slots[4]);
            }
            """;

        var ptx = MathBlockCudaDeviceModule.CompilePtx(source, "external-nested-formula.cu");

        Assert.True(ptx.Length > 1_000);
        Assert.Contains(
            ".entry external_nested_formula",
            Encoding.UTF8.GetString(ptx),
            StringComparison.Ordinal);
    }

    [Fact]
    public void CUDA_device_ABI_fingerprint_binds_the_exact_source_and_dispatch_table()
    {
        var expectedSourceFingerprint = Convert.ToHexString(
            SHA256.HashData(Encoding.UTF8.GetBytes(MathBlockCudaDeviceModule.Source)));

        Assert.Equal(expectedSourceFingerprint, MathBlockCudaDeviceModule.SourceFingerprint);
        Assert.Equal(64, MathBlockCudaDeviceModule.AbiFingerprint.Length);
        Assert.Equal(
            MathBlockCudaDeviceModule.Operations.Count,
            MathBlockCudaDeviceModule.Operations.Select(contract => contract.Fingerprint).Distinct().Count());
        Assert.Contains(
            $"__device__ void {MathBlockCudaDeviceModule.DispatchFunctionName}",
            MathBlockCudaDeviceModule.Source,
            StringComparison.Ordinal);
    }

    private static int PayloadCount(MathBlockValue value)
    {
        if (!value.IsValid)
            return 0;
        return MathBlockCudaValueCodec.GetElementCount(value);
    }
}
