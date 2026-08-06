using System.Runtime.InteropServices;
using System.Reflection;
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
        Assert.Equal(MathBlockCudaGraphEdgeLayout.Size, Marshal.SizeOf<MathBlockCudaGraphEdgeDescriptor>());
        Assert.Equal(
            MathBlockCudaGraphEdgeLayout.FromOffset,
            Marshal.OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.From)).ToInt32());
        Assert.Equal(
            MathBlockCudaGraphEdgeLayout.ToOffset,
            Marshal.OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.To)).ToInt32());
        Assert.Equal(
            MathBlockCudaGraphEdgeLayout.WeightOffset,
            Marshal.OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.Weight)).ToInt32());
        Assert.Equal(MathBlockCudaRunLayout.Size, Marshal.SizeOf<MathBlockCudaRunDescriptor>());
        Assert.Equal(
            MathBlockCudaRunLayout.StartOffset,
            Marshal.OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Start)).ToInt32());
        Assert.Equal(
            MathBlockCudaRunLayout.LengthOffset,
            Marshal.OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Length)).ToInt32());
        Assert.Equal(
            MathBlockCudaRunLayout.ValueOffset,
            Marshal.OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Value)).ToInt32());

        foreach (var contract in contracts)
        {
            Assert.Equal(MathBlockCudaDeviceModule.DispatcherBlockSize, contract.RequiredBlockSize);
            Assert.True(contract.NativeBlockSize is 1u or 128u);
            Assert.Equal(64, contract.Fingerprint.Length);
            Assert.Equal(64, contract.PerformanceEvidenceFingerprint.Length);
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
    public void CUDA_operation_fingerprint_changes_for_each_performance_field_group()
    {
        var operation = MathBlockCatalog.Standard.Get("scalar.add", 1);
        var contract = MathBlockCudaDeviceModule.GetOperation(operation.Identity);
        var performance = operation.PerformanceCase;
        var baseline = CreateContract(operation, contract, performance);

        Assert.Equal(contract.PerformanceEvidenceFingerprint, baseline.PerformanceEvidenceFingerprint);
        Assert.Equal(contract.Fingerprint, baseline.Fingerprint);

        var changedInputs = performance.Inputs.ToArray();
        var first = changedInputs[0];
        changedInputs[0] = MathBlockValue.Scalar(first.AsScalar() + 0.125d, first.Type.Unit);
        var inputChange = CreateContract(
            operation,
            contract,
            new MathBlockPerformanceCase(
                changedInputs,
                performance.Iterations,
                performance.MaximumWarmLatencyMicroseconds));
        var iterationChange = CreateContract(
            operation,
            contract,
            new MathBlockPerformanceCase(
                performance.Inputs,
                checked(performance.Iterations + 1),
                performance.MaximumWarmLatencyMicroseconds));
        var changedLatency = performance.MaximumWarmLatencyMicroseconds == 1_000d
            ? 999d
            : performance.MaximumWarmLatencyMicroseconds + 0.125d;
        var latencyChange = CreateContract(
            operation,
            contract,
            new MathBlockPerformanceCase(
                performance.Inputs,
                performance.Iterations,
                changedLatency));
        var invalidInputsA = performance.Inputs.ToArray();
        invalidInputsA[0] = MathBlockValue.Invalid(first.Type, "Invalid performance input A.");
        var invalidInputsB = performance.Inputs.ToArray();
        invalidInputsB[0] = MathBlockValue.Invalid(first.Type, "Invalid performance input B.");
        var invalidReasonA = CreateContract(
            operation,
            contract,
            new MathBlockPerformanceCase(
                invalidInputsA,
                performance.Iterations,
                performance.MaximumWarmLatencyMicroseconds));
        var invalidReasonB = CreateContract(
            operation,
            contract,
            new MathBlockPerformanceCase(
                invalidInputsB,
                performance.Iterations,
                performance.MaximumWarmLatencyMicroseconds));

        Assert.NotEqual(baseline.PerformanceEvidenceFingerprint, inputChange.PerformanceEvidenceFingerprint);
        Assert.NotEqual(baseline.PerformanceEvidenceFingerprint, iterationChange.PerformanceEvidenceFingerprint);
        Assert.NotEqual(baseline.PerformanceEvidenceFingerprint, latencyChange.PerformanceEvidenceFingerprint);
        Assert.NotEqual(invalidReasonA.PerformanceEvidenceFingerprint, invalidReasonB.PerformanceEvidenceFingerprint);
        Assert.NotEqual(baseline.Fingerprint, inputChange.Fingerprint);
        Assert.NotEqual(baseline.Fingerprint, iterationChange.Fingerprint);
        Assert.NotEqual(baseline.Fingerprint, latencyChange.Fingerprint);
        Assert.NotEqual(invalidReasonA.Fingerprint, invalidReasonB.Fingerprint);
    }

    [Fact]
    public void CUDA_device_ABI_fingerprint_changes_for_each_public_field_group()
    {
        var abi = MathBlockCudaDeviceModule.Abi;

        Assert.Equal(MathBlockCudaDeviceModule.AbiFingerprint, abi.Fingerprint);
        Assert.Equal(MathBlockCudaDeviceModule.DispatchSignature, abi.DispatchSignature);
        Assert.Equal(MathBlockCudaSlotLayout.Size, abi.Slot.Size);
        Assert.Equal(MathBlockCudaSlotLayout.CapacityOffset, abi.Slot.CapacityOffset);
        Assert.Equal(MathBlockCudaGraphEdgeLayout.Size, abi.GraphEdge.Size);
        Assert.Equal(MathBlockCudaGraphEdgeLayout.WeightOffset, abi.GraphEdge.WeightOffset);
        Assert.Equal(MathBlockCudaRunLayout.Size, abi.Run.Size);
        Assert.Equal(MathBlockCudaRunLayout.ValueOffset, abi.Run.ValueOffset);
        Assert.Equal(MathBlockCudaValueCodec.Schema, abi.ValueCodecSchema);
        Assert.Equal(
            MathBlockCudaValueCodec.ImplementationFingerprint,
            abi.ValueCodecImplementationFingerprint);
        Assert.Equal(64, abi.SourceFingerprint.Length);
        Assert.Equal(64, abi.OperationTableFingerprint.Length);

        AssertChanged(abi with { DispatchSignature = abi.DispatchSignature + " " });
        AssertChanged(abi with
        {
            GraphEdge = abi.GraphEdge with { WeightOffset = checked(abi.GraphEdge.WeightOffset + 1) }
        });
        AssertChanged(abi with
        {
            Run = abi.Run with { ValueOffset = checked(abi.Run.ValueOffset + 1) }
        });
        AssertChanged(abi with
        {
            ValueCodecSchema = abi.ValueCodecSchema with
            {
                Version = checked(abi.ValueCodecSchema.Version + 1)
            }
        });
        AssertChanged(abi with
        {
            ValueCodecSchema = abi.ValueCodecSchema with
            {
                Definition = abi.ValueCodecSchema.Definition + "\nchanged=1"
            }
        });
        AssertChanged(abi with
        {
            ValueCodecImplementationFingerprint = abi.ValueCodecImplementationFingerprint + "0"
        });

        void AssertChanged(MathBlockCudaDeviceAbi changed) =>
            Assert.NotEqual(abi.Fingerprint, changed.Fingerprint);
    }

    [Fact]
    public void CUDA_value_codec_round_trips_every_public_value_kind()
    {
        var values = MathBlockCatalog.Standard.Operations
            .SelectMany(operation => operation.RegressionCases)
            .SelectMany(item => item.Inputs.Append(item.Expected))
            .Where(value => value.IsValid)
            .GroupBy(value => value.Type.Kind)
            .ToDictionary(group => group.Key, group => group.First());

        Assert.Equal(
            Enum.GetValues<MathBlockValueKind>().OrderBy(value => value),
            values.Keys.OrderBy(value => value));
        Assert.Equal(64, MathBlockCudaValueCodec.SchemaFingerprint.Length);
        Assert.Equal(64, MathBlockCudaValueCodec.ImplementationFingerprint.Length);

        foreach (var value in values.Values)
        {
            var capacity = MathBlockCudaValueCodec.GetElementCount(value);
            var payloadBytes = MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, capacity);
            var byteCount = checked(MathBlockCudaSlotLayout.Size + payloadBytes);
            var arena = Marshal.AllocHGlobal(byteCount);
            try
            {
                MathBlockCudaValueCodec.WriteValue(
                    arena,
                    0,
                    payloadBytes == 0 ? -1 : MathBlockCudaSlotLayout.Size,
                    0ul,
                    0ul,
                    capacity,
                    value);
                var decoded = MathBlockCudaValueCodec.ReadValue(
                    arena,
                    0,
                    payloadBytes == 0 ? -1 : MathBlockCudaSlotLayout.Size,
                    value.Type);
                Assert.True(
                    value.ApproximatelyEquals(decoded, 0d),
                    $"The CUDA value codec changed '{value.Type.Kind}'.");
            }
            finally
            {
                Marshal.FreeHGlobal(arena);
            }
        }
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

    private static MathBlockCudaOperationContract CreateContract(
        MathBlockOperation operation,
        MathBlockCudaOperationContract template,
        MathBlockPerformanceCase performanceCase)
    {
        var clone = new MathBlockOperation(
            operation.Identifier,
            operation.Version,
            operation.Arity,
            inputTypes => operation.ResolveOutputType(inputTypes),
            inputs => operation.Evaluate(inputs),
            operation.RegressionCases,
            performanceCase);
        var constructor = Assert.Single(
            typeof(MathBlockCudaOperationContract).GetConstructors(
                BindingFlags.Instance | BindingFlags.NonPublic));
        return Assert.IsType<MathBlockCudaOperationContract>(constructor.Invoke(
            [
                clone,
                template.Family,
                template.Opcode,
                template.NativeBlockSize,
                MathBlockCudaDeviceModule.SourceFingerprint
            ]));
    }

    private static int PayloadCount(MathBlockValue value)
    {
        if (!value.IsValid)
            return 0;
        return MathBlockCudaValueCodec.GetElementCount(value);
    }
}
