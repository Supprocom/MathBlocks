using System.Security.Cryptography;
using System.Runtime.InteropServices;
using System.Text;
using System.Globalization;

namespace Supprocom.MathBlocks.Cuda;

public enum MathBlockCudaOperationFamily
{
    Advanced,
    Complex,
    Geometry,
    Graph,
    Matrix,
    Probability,
    Scalar,
    SequencePath,
    Statistics,
    Transport,
    Vector
}

public enum MathBlockCudaExecutionBehavior
{
    SingleThread,
    CooperativeBlock
}

public static class MathBlockCudaSlotLayout
{
    public const int Size = 48;
    public const int ScalarValueOffset = 0;
    public const int DataPointerOffset = 8;
    public const int ScratchPointerOffset = 16;
    public const int BooleanValueOffset = 24;
    public const int ValidOffset = 28;
    public const int RowsOffset = 32;
    public const int ColumnsOffset = 36;
    public const int CountOffset = 40;
    public const int CapacityOffset = 44;
}

[StructLayout(LayoutKind.Explicit, Size = MathBlockCudaSlotLayout.Size)]
public struct MathBlockCudaSlotDescriptor
{
    [FieldOffset(MathBlockCudaSlotLayout.ScalarValueOffset)]
    public double ScalarValue;

    [FieldOffset(MathBlockCudaSlotLayout.DataPointerOffset)]
    public ulong DataPointer;

    [FieldOffset(MathBlockCudaSlotLayout.ScratchPointerOffset)]
    public ulong ScratchPointer;

    [FieldOffset(MathBlockCudaSlotLayout.BooleanValueOffset)]
    public int BooleanValue;

    [FieldOffset(MathBlockCudaSlotLayout.ValidOffset)]
    public int Valid;

    [FieldOffset(MathBlockCudaSlotLayout.RowsOffset)]
    public int Rows;

    [FieldOffset(MathBlockCudaSlotLayout.ColumnsOffset)]
    public int Columns;

    [FieldOffset(MathBlockCudaSlotLayout.CountOffset)]
    public int Count;

    [FieldOffset(MathBlockCudaSlotLayout.CapacityOffset)]
    public int Capacity;
}

[StructLayout(LayoutKind.Sequential)]
public struct MathBlockCudaGraphEdgeDescriptor
{
    public int From;
    public int To;
    public double Weight;
}

[StructLayout(LayoutKind.Sequential)]
public struct MathBlockCudaRunDescriptor
{
    public int Start;
    public int Length;
    public double Value;
}

public sealed class MathBlockCudaContractCase
{
    internal MathBlockCudaContractCase(
        string name,
        IReadOnlyList<MathBlockType> operandTypes,
        MathBlockCudaOperationPlan plan,
        string evidenceFingerprint)
    {
        Name = name;
        OperandTypes = operandTypes;
        Plan = plan;
        EvidenceFingerprint = evidenceFingerprint;
    }

    public string Name { get; }
    public IReadOnlyList<MathBlockType> OperandTypes { get; }
    public MathBlockCudaOperationPlan Plan { get; }
    public string EvidenceFingerprint { get; }
}

public readonly record struct MathBlockCudaOperationPlan(
    MathBlockType OutputType,
    int OutputCapacity,
    int OutputRows,
    int OutputColumns,
    int ScratchBytes);

public sealed class MathBlockCudaOperationContract
{
    private readonly MathBlockOperation operation;
    private readonly IReadOnlyList<MathBlockCudaContractCase> contractCases;

    internal MathBlockCudaOperationContract(
        MathBlockOperation operation,
        MathBlockCudaOperationFamily family,
        int opcode,
        uint nativeBlockSize,
        string deviceSourceFingerprint)
    {
        this.operation = operation;
        Family = family;
        Opcode = opcode;
        NativeBlockSize = nativeBlockSize;
        ExecutionBehavior = nativeBlockSize == 1
            ? MathBlockCudaExecutionBehavior.SingleThread
            : MathBlockCudaExecutionBehavior.CooperativeBlock;
        OperandTypeRule = $"{operation.Identity}/operand-type";
        OutputTypeRule = $"{operation.Identity}/output-type";
        UnitRule = $"{operation.Identity}/unit";
        ShapeRule = $"{operation.Identity}/shape";
        CapacityRule = $"{operation.Identity}/capacity";
        ScratchRule = $"{operation.Identity}/scratch";
        ValidityRule = $"{operation.Identity}/validity";
        ExecutionRule = $"{operation.Identity}/execution";
        var cases = new MathBlockCudaContractCase[operation.RegressionCases.Count];
        var fingerprintSource = new StringBuilder(
            $"mathblocks-cuda-operation-contract-v2\n" +
            $"{operation.Identifier}\n{operation.Version}\n{operation.Arity}\n" +
            $"{(int)family}\n{opcode}\n{RequiredBlockSize}\n{nativeBlockSize}\n" +
            $"{(int)ExecutionBehavior}\n" +
            $"{OperandTypeRule}\n{OutputTypeRule}\n{UnitRule}\n{ShapeRule}\n" +
            $"{CapacityRule}\n{ScratchRule}\n{ValidityRule}\n{ExecutionRule}\n" +
            deviceSourceFingerprint + "\n");
        for (var index = 0; index < operation.RegressionCases.Count; index++)
        {
            var regression = operation.RegressionCases[index];
            var operandTypes = new MathBlockType[regression.Inputs.Count];
            var evidence = new StringBuilder(regression.Name).Append('\n');
            for (var operandIndex = 0; operandIndex < regression.Inputs.Count; operandIndex++)
            {
                var input = regression.Inputs[operandIndex];
                operandTypes[operandIndex] = input.Type;
                evidence.Append(input.Type).Append('\n')
                    .Append(MathBlockCudaContractHash.CreateValue(input)).Append('\n');
            }
            var plan = PlanCUDA(regression.Inputs);
            evidence.Append(regression.Expected.Type).Append('\n')
                .Append(MathBlockCudaContractHash.CreateValue(regression.Expected)).Append('\n')
                .Append(regression.Expected.InvalidReason).Append('\n')
                .Append(regression.Tolerance.ToString("R", CultureInfo.InvariantCulture)).Append('\n')
                .Append(plan.OutputType).Append('\n')
                .Append(plan.OutputCapacity).Append('\n')
                .Append(plan.OutputRows).Append('\n')
                .Append(plan.OutputColumns).Append('\n')
                .Append(plan.ScratchBytes).Append('\n');
            var evidenceFingerprint = MathBlockCudaContractHash.Create(evidence.ToString());
            cases[index] = new MathBlockCudaContractCase(
                regression.Name,
                Array.AsReadOnly(operandTypes),
                plan,
                evidenceFingerprint);
            fingerprintSource.Append(evidenceFingerprint).Append('\n');
        }
        contractCases = Array.AsReadOnly(cases);
        Fingerprint = MathBlockCudaContractHash.Create(fingerprintSource.ToString());
    }

    public string Identifier => operation.Identifier;
    public int Version => operation.Version;
    public int Arity => operation.Arity;
    public string Identity => operation.Identity;
    public MathBlockCudaOperationFamily Family { get; }
    public int Opcode { get; }
    public int RequiredBlockSize => MathBlockCudaDeviceModule.DispatcherBlockSize;
    public uint NativeBlockSize { get; }
    public MathBlockCudaExecutionBehavior ExecutionBehavior { get; }
    public string OperandTypeRule { get; }
    public string OutputTypeRule { get; }
    public string UnitRule { get; }
    public string ShapeRule { get; }
    public string CapacityRule { get; }
    public string ScratchRule { get; }
    public string ValidityRule { get; }
    public string ExecutionRule { get; }
    public string Fingerprint { get; }
    public IReadOnlyList<MathBlockRegressionCase> RegressionCases => operation.RegressionCases;
    public MathBlockPerformanceCase PerformanceCase => operation.PerformanceCase;

    public IReadOnlyList<MathBlockCudaContractCase> GetContractCases()
    {
        return contractCases;
    }

    public MathBlockType ResolveOutputType(IReadOnlyList<MathBlockType> inputTypes) =>
        operation.ResolveOutputType(inputTypes);

    public MathBlockValue EvaluateCPU(params MathBlockValue[] inputs) =>
        operation.Evaluate(inputs);

    public MathBlockValue EvaluateCPU(IReadOnlyList<MathBlockValue> inputs) =>
        operation.Evaluate(inputs);

    public MathBlockCudaOperationPlan PlanCUDA(IReadOnlyList<MathBlockValue> prototypeInputs)
    {
        ArgumentNullException.ThrowIfNull(prototypeInputs);
        if (prototypeInputs.Count != Arity)
        {
            throw new ArgumentException(
                $"Operation '{Identity}' requires {Arity} prototype inputs.",
                nameof(prototypeInputs));
        }

        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var indexes = new int[prototypeInputs.Count];
        var prototypes = new Dictionary<string, MathBlockValue>(prototypeInputs.Count, StringComparer.Ordinal);
        for (var index = 0; index < prototypeInputs.Count; index++)
        {
            var value = prototypeInputs[index];
            if (!value.IsValid)
                throw new ArgumentException("A CUDA prototype input must be valid.", nameof(prototypeInputs));
            var name = $"input{index}";
            indexes[index] = builder.Input(name, value.Type);
            prototypes.Add(name, value);
        }

        var output = builder.Apply(Identifier, Version, indexes);
        var program = builder.Output("output", output).Build();
        MathBlocksCUDAProgram.ValidateProgram(program);
        var layout = MathBlocksCUDAProgram.ResolvePayloadLayout(program.PlanNodes, prototypes);
        var outputNode = program.PlanNodes[output];
        var scratchBytes = MathBlocksCUDAProgram.ResolveScratchBytes(
            outputNode,
            program.PlanNodes,
            layout);
        return new MathBlockCudaOperationPlan(
            outputNode.Type,
            layout.Capacities[output],
            layout.ShapeRows[output],
            layout.ShapeColumns[output],
            scratchBytes);
    }
}

public static class MathBlockCudaDeviceModule
{
    private static readonly Lazy<ModuleState> state = new(
        CreateState,
        LazyThreadSafetyMode.ExecutionAndPublication);

    public const int AbiVersion = 1;
    public const int DispatcherBlockSize = 128;
    public const string DispatchFunctionName = "mathblocks_operation_dispatch";
    public const string DispatchSignature =
        "__device__ void mathblocks_operation_dispatch(int family, int opcode, " +
        "const MathBlockSlot* const* inputs, int input_count, MathBlockSlot* output)";

    public static string Source => state.Value.Source;
    public static string SourceFingerprint => state.Value.SourceFingerprint;
    public static string AbiFingerprint => state.Value.AbiFingerprint;
    public static IReadOnlyList<MathBlockCudaOperationContract> Operations => state.Value.Operations;
    public static IReadOnlyCollection<string> SupportedOperationIdentities =>
        state.Value.SupportedOperationIdentities;

    public static MathBlockCudaOperationContract GetOperation(string identity)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(identity);
        return state.Value.ContractsByIdentity.TryGetValue(identity, out var contract)
            ? contract
            : throw new KeyNotFoundException($"CUDA operation '{identity}' is not registered.");
    }

    public static string ComposeSource(string consumerSource)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(consumerSource);
        return Source + "\n" + consumerSource;
    }

    public static byte[] CompilePtx(string consumerSource, string sourceName = "mathblocks-consumer.cu")
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(sourceName);
        return MathBlocksCudaNative.CompilePtx(ComposeSource(consumerSource), sourceName);
    }

    private static ModuleState CreateState()
    {
        var source = CreateSource();
        var sourceFingerprint = MathBlockCudaContractHash.Create(source);
        var registryOperations = MathBlockCatalog.Standard.Operations;
        var contracts = new MathBlockCudaOperationContract[registryOperations.Count];
        var contractsByIdentity = new Dictionary<string, MathBlockCudaOperationContract>(
            registryOperations.Count,
            StringComparer.Ordinal);
        var identities = new string[registryOperations.Count];
        for (var index = 0; index < registryOperations.Count; index++)
        {
            var operation = registryOperations[index];
            var feature = MathBlockCudaFeatureIndex.Resolve(operation.Identity);
            var family = (MathBlockCudaOperationFamily)(int)feature.Family;
            var contract = new MathBlockCudaOperationContract(
                operation,
                family,
                feature.Opcode,
                ResolveBlockSize(feature.Family),
                sourceFingerprint);
            contracts[index] = contract;
            contractsByIdentity.Add(contract.Identity, contract);
            identities[index] = contract.Identity;
        }

        var fingerprint = new StringBuilder();
        fingerprint.Append("mathblocks-cuda-device-abi-v1\n")
            .Append(AbiVersion).Append('\n')
            .Append(DispatcherBlockSize).Append('\n')
            .Append(DispatchFunctionName).Append('\n')
            .Append(MathBlockCudaSlotLayout.Size).Append('\n')
            .Append(MathBlockCudaSlotLayout.ScalarValueOffset).Append('\n')
            .Append(MathBlockCudaSlotLayout.DataPointerOffset).Append('\n')
            .Append(MathBlockCudaSlotLayout.ScratchPointerOffset).Append('\n')
            .Append(MathBlockCudaSlotLayout.BooleanValueOffset).Append('\n')
            .Append(MathBlockCudaSlotLayout.ValidOffset).Append('\n')
            .Append(MathBlockCudaSlotLayout.RowsOffset).Append('\n')
            .Append(MathBlockCudaSlotLayout.ColumnsOffset).Append('\n')
            .Append(MathBlockCudaSlotLayout.CountOffset).Append('\n')
            .Append(MathBlockCudaSlotLayout.CapacityOffset).Append('\n')
            .Append(sourceFingerprint).Append('\n');
        for (var index = 0; index < contracts.Length; index++)
            fingerprint.Append(contracts[index].Fingerprint).Append('\n');

        return new ModuleState(
            source,
            sourceFingerprint,
            MathBlockCudaContractHash.Create(fingerprint.ToString()),
            Array.AsReadOnly(contracts),
            contractsByIdentity,
            Array.AsReadOnly(identities));
    }

    private static string CreateSource()
    {
        var builder = new StringBuilder();
        AppendDeviceCatalog(builder, ScalarCudaBlockCatalog.KernelSource, "mathblocks_scalar");
        AppendDeviceCatalog(builder, VectorCudaBlockCatalog.KernelSource, "mathblocks_vector");
        AppendDeviceCatalog(builder, ComplexCudaBlockCatalog.KernelSource, "mathblocks_complex");
        AppendDeviceCatalog(builder, MatrixCudaBlockCatalog.KernelSource, "mathblocks_matrix");
        AppendDeviceCatalog(builder, ProbabilityCudaBlockCatalog.KernelSource, "mathblocks_probability");
        AppendDeviceCatalog(builder, SequencePathCudaBlockCatalog.KernelSource, "mathblocks_sequence_path");
        AppendDeviceCatalog(builder, StatisticsCudaBlockCatalog.KernelSource, "mathblocks_statistics");
        AppendDeviceCatalog(builder, GeometryCudaBlockCatalog.KernelSource, "mathblocks_geometry");
        AppendDeviceCatalog(builder, GraphCudaBlockCatalog.KernelSource, "mathblocks_graph");
        AppendDeviceCatalog(builder, AdvancedCudaBlockCatalog.KernelSource, "mathblocks_advanced");
        AppendDeviceCatalog(builder, TransportCudaBlockCatalog.KernelSource, "mathblocks_transport");
        builder.Append('\n').Append(DeviceDispatchSource);
        return builder.ToString();
    }

    private static void AppendDeviceCatalog(StringBuilder builder, string source, string entryPoint)
    {
        var globalDeclaration = $"extern \"C\" __global__ void {entryPoint}(";
        var deviceDeclaration = $"__device__ void {entryPoint}_dispatch(";
        var declarationIndex = source.IndexOf(globalDeclaration, StringComparison.Ordinal);
        if (declarationIndex < 0 ||
            source.IndexOf(globalDeclaration, declarationIndex + globalDeclaration.Length, StringComparison.Ordinal) >= 0)
        {
            throw new InvalidOperationException($"CUDA entry point '{entryPoint}' is not unique.");
        }

        var deviceSource = source.Replace(
            globalDeclaration,
            deviceDeclaration,
            StringComparison.Ordinal);
        deviceSource = entryPoint == "mathblocks_scalar"
            ? deviceSource.Replace("blockIdx.x != 0 || ", string.Empty, StringComparison.Ordinal)
            : deviceSource.Replace("blockIdx.x != 0", "false", StringComparison.Ordinal);
        builder.Append(deviceSource).Append('\n');
    }

    private static uint ResolveBlockSize(MathBlockCudaFamily family) => family switch
    {
        MathBlockCudaFamily.Scalar => 1,
        MathBlockCudaFamily.Vector => VectorCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.Complex => ComplexCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.Matrix => MatrixCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.Probability => ProbabilityCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.SequencePath => SequencePathCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.Statistics => StatisticsCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.Geometry => GeometryCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.Graph => GraphCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.Advanced => AdvancedCudaBlockCatalog.BlockSize,
        MathBlockCudaFamily.Transport => TransportCudaBlockCatalog.BlockSize,
        _ => throw new InvalidOperationException($"CUDA family '{family}' is not supported.")
    };

    private const string DeviceDispatchSource = """
        __device__ void mathblocks_operation_dispatch(
            int family,
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            switch (family)
            {
                case 0: mathblocks_advanced_dispatch(opcode, inputs, input_count, output); break;
                case 1: mathblocks_complex_dispatch(opcode, inputs, input_count, output); break;
                case 2: mathblocks_geometry_dispatch(opcode, inputs, input_count, output); break;
                case 3: mathblocks_graph_dispatch(opcode, inputs, input_count, output); break;
                case 4: mathblocks_matrix_dispatch(opcode, inputs, input_count, output); break;
                case 5: mathblocks_probability_dispatch(opcode, inputs, input_count, output); break;
                case 6: mathblocks_scalar_dispatch(opcode, inputs, input_count, output); break;
                case 7: mathblocks_sequence_path_dispatch(opcode, inputs, input_count, output); break;
                case 8: mathblocks_statistics_dispatch(opcode, inputs, input_count, output); break;
                case 9: mathblocks_transport_dispatch(opcode, inputs, input_count, output); break;
                case 10: mathblocks_vector_dispatch(opcode, inputs, input_count, output); break;
                default:
                    if (threadIdx.x == 0)
                    {
                        output->valid = 0;
                        output->count = 0;
                    }
                    break;
            }
            __syncthreads();
        }

        extern "C" __global__ void mathblocks_scalar(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_scalar_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_vector(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_vector_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_complex(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_complex_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_matrix(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_matrix_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_probability(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_probability_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_sequence_path(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_sequence_path_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_statistics(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_statistics_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_geometry(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_geometry_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_graph(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_graph_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_advanced(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_advanced_dispatch(opcode, inputs, input_count, output);
        }

        extern "C" __global__ void mathblocks_transport(
            int opcode,
            const MathBlockSlot* const* inputs,
            int input_count,
            MathBlockSlot* output)
        {
            mathblocks_transport_dispatch(opcode, inputs, input_count, output);
        }
        """;

    private sealed record ModuleState(
        string Source,
        string SourceFingerprint,
        string AbiFingerprint,
        IReadOnlyList<MathBlockCudaOperationContract> Operations,
        IReadOnlyDictionary<string, MathBlockCudaOperationContract> ContractsByIdentity,
        IReadOnlyCollection<string> SupportedOperationIdentities);
}

internal static class MathBlockCudaContractHash
{
    public static string Create(string value) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(value)));

    public static unsafe string CreateValue(MathBlockValue value)
    {
        var capacity = value.IsValid ? MathBlockCudaValueCodec.GetElementCount(value) : 0;
        var payloadBytes = MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, capacity);
        var byteCount = checked(MathBlockCudaSlotLayout.Size + payloadBytes);
        var arena = Marshal.AllocHGlobal(byteCount);
        try
        {
            new Span<byte>((void*)arena, byteCount).Clear();
            MathBlockCudaValueCodec.WriteValue(
                arena,
                0,
                payloadBytes == 0 ? -1 : MathBlockCudaSlotLayout.Size,
                0ul,
                0ul,
                capacity,
                value);
            var bytes = new byte[byteCount];
            Marshal.Copy(arena, bytes, 0, byteCount);
            return Convert.ToHexString(SHA256.HashData(bytes));
        }
        finally
        {
            Marshal.FreeHGlobal(arena);
        }
    }
}
