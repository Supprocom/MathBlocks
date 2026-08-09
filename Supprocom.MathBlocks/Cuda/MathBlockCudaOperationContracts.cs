using System.Globalization;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

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

public static class MathBlockCudaGraphEdgeLayout
{
    public const int Size = 16;
    public const int FromOffset = 0;
    public const int ToOffset = 4;
    public const int WeightOffset = 8;
}

public static class MathBlockCudaRunLayout
{
    public const int Size = 16;
    public const int StartOffset = 0;
    public const int LengthOffset = 4;
    public const int ValueOffset = 8;
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

[StructLayout(LayoutKind.Explicit, Size = MathBlockCudaGraphEdgeLayout.Size)]
public struct MathBlockCudaGraphEdgeDescriptor
{
    [FieldOffset(MathBlockCudaGraphEdgeLayout.FromOffset)]
    public int From;

    [FieldOffset(MathBlockCudaGraphEdgeLayout.ToOffset)]
    public int To;

    [FieldOffset(MathBlockCudaGraphEdgeLayout.WeightOffset)]
    public double Weight;
}

[StructLayout(LayoutKind.Explicit, Size = MathBlockCudaRunLayout.Size)]
public struct MathBlockCudaRunDescriptor
{
    [FieldOffset(MathBlockCudaRunLayout.StartOffset)]
    public int Start;

    [FieldOffset(MathBlockCudaRunLayout.LengthOffset)]
    public int Length;

    [FieldOffset(MathBlockCudaRunLayout.ValueOffset)]
    public double Value;
}

public readonly record struct MathBlockCudaSlotAbi(
    int Size,
    int ScalarValueOffset,
    int DataPointerOffset,
    int ScratchPointerOffset,
    int BooleanValueOffset,
    int ValidOffset,
    int RowsOffset,
    int ColumnsOffset,
    int CountOffset,
    int CapacityOffset);

public readonly record struct MathBlockCudaGraphEdgeAbi(
    int Size,
    int FromOffset,
    int ToOffset,
    int WeightOffset);

public readonly record struct MathBlockCudaRunAbi(
    int Size,
    int StartOffset,
    int LengthOffset,
    int ValueOffset);

public readonly record struct MathBlockCudaDeviceAbi(
    int Version,
    int DispatcherBlockSize,
    string DispatchFunctionName,
    string DispatchSignature,
    MathBlockCudaSlotAbi Slot,
    MathBlockCudaGraphEdgeAbi GraphEdge,
    MathBlockCudaRunAbi Run,
    MathBlockCudaValueCodecSchema ValueCodecSchema,
    string ValueCodecImplementationFingerprint,
    string SourceFingerprint,
    string OperationTableFingerprint)
{
    public string Fingerprint => MathBlockCudaContractHash.Create(CreateFingerprintMaterial());

    private string CreateFingerprintMaterial()
    {
        var builder = new StringBuilder("mathblocks-cuda-device-abi-v2\n");
        Append(builder, Version);
        Append(builder, DispatcherBlockSize);
        Append(builder, DispatchFunctionName);
        Append(builder, DispatchSignature);
        Append(builder, Slot.Size);
        Append(builder, Slot.ScalarValueOffset);
        Append(builder, Slot.DataPointerOffset);
        Append(builder, Slot.ScratchPointerOffset);
        Append(builder, Slot.BooleanValueOffset);
        Append(builder, Slot.ValidOffset);
        Append(builder, Slot.RowsOffset);
        Append(builder, Slot.ColumnsOffset);
        Append(builder, Slot.CountOffset);
        Append(builder, Slot.CapacityOffset);
        Append(builder, GraphEdge.Size);
        Append(builder, GraphEdge.FromOffset);
        Append(builder, GraphEdge.ToOffset);
        Append(builder, GraphEdge.WeightOffset);
        Append(builder, Run.Size);
        Append(builder, Run.StartOffset);
        Append(builder, Run.LengthOffset);
        Append(builder, Run.ValueOffset);
        Append(builder, ValueCodecSchema.Version);
        Append(builder, ValueCodecSchema.Fingerprint);
        Append(builder, ValueCodecImplementationFingerprint);
        Append(builder, SourceFingerprint);
        Append(builder, OperationTableFingerprint);
        return builder.ToString();
    }

    private static void Append(StringBuilder builder, int value) =>
        builder.Append(value.ToString(CultureInfo.InvariantCulture)).Append('\n');

    private static void Append(StringBuilder builder, string value) =>
        builder.Append(value).Append('\n');
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
        PerformanceEvidenceFingerprint = CreatePerformanceEvidenceFingerprint(
            operation.PerformanceCase);
        var fingerprintSource = new StringBuilder(
            $"mathblocks-cuda-operation-contract-v3\n" +
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
                    .Append(MathBlockCudaContractHash.CreateValue(input)).Append('\n')
                    .Append(input.InvalidReason).Append('\n');
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
        fingerprintSource.Append(PerformanceEvidenceFingerprint).Append('\n');
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
    public string PerformanceEvidenceFingerprint { get; }
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

    private static string CreatePerformanceEvidenceFingerprint(
        MathBlockPerformanceCase performanceCase)
    {
        var evidence = new StringBuilder("mathblocks-cuda-performance-evidence-v1\n");
        evidence.Append(performanceCase.Inputs.Count.ToString(CultureInfo.InvariantCulture))
            .Append('\n');
        for (var index = 0; index < performanceCase.Inputs.Count; index++)
        {
            var input = performanceCase.Inputs[index];
            evidence.Append(input.Type).Append('\n')
                .Append(MathBlockCudaContractHash.CreateValue(input)).Append('\n')
                .Append(input.InvalidReason).Append('\n');
        }
        evidence.Append(performanceCase.Iterations.ToString(CultureInfo.InvariantCulture))
            .Append('\n')
            .Append(performanceCase.MaximumWarmLatencyMicroseconds.ToString(
                "R",
                CultureInfo.InvariantCulture))
            .Append('\n');
        return MathBlockCudaContractHash.Create(evidence.ToString());
    }
}

public static class MathBlockCudaDeviceModule
{
    private static readonly Lazy<ModuleState> state = new(
        CreateState,
        LazyThreadSafetyMode.ExecutionAndPublication);

    public const int AbiVersion = 2;
    public const int DispatcherBlockSize = 128;
    public const string DispatchFunctionName = "mathblocks_operation_dispatch";
    public const string DispatchSignature =
        "__device__ void mathblocks_operation_dispatch(int family, int opcode, " +
        "const MathBlockSlot* const* inputs, int input_count, MathBlockSlot* output)";

    public static string Source => state.Value.Source;
    public static string SourceFingerprint => state.Value.SourceFingerprint;
    public static MathBlockCudaDeviceAbi Abi => state.Value.Abi;
    public static string AbiFingerprint => state.Value.Abi.Fingerprint;
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

        var operationTable = new StringBuilder("mathblocks-cuda-operation-table-v1\n");
        for (var index = 0; index < contracts.Length; index++)
        {
            operationTable.Append(contracts[index].Identity).Append('\n')
                .Append(contracts[index].Family).Append('\n')
                .Append(((int)contracts[index].Family).ToString(CultureInfo.InvariantCulture))
                .Append('\n')
                .Append(contracts[index].Opcode.ToString(CultureInfo.InvariantCulture))
                .Append('\n')
                .Append(contracts[index].Fingerprint).Append('\n');
        }
        var operationTableFingerprint = MathBlockCudaContractHash.Create(
            operationTable.ToString());
        var abi = new MathBlockCudaDeviceAbi(
            AbiVersion,
            DispatcherBlockSize,
            DispatchFunctionName,
            DispatchSignature,
            new MathBlockCudaSlotAbi(
                Marshal.SizeOf<MathBlockCudaSlotDescriptor>(),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.ScalarValue)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.DataPointer)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.ScratchPointer)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.BooleanValue)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Valid)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Rows)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Columns)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Count)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Capacity))),
            new MathBlockCudaGraphEdgeAbi(
                Marshal.SizeOf<MathBlockCudaGraphEdgeDescriptor>(),
                OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.From)),
                OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.To)),
                OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.Weight))),
            new MathBlockCudaRunAbi(
                Marshal.SizeOf<MathBlockCudaRunDescriptor>(),
                OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Start)),
                OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Length)),
                OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Value))),
            MathBlockCudaValueCodec.Schema,
            MathBlockCudaValueCodec.ImplementationFingerprint,
            sourceFingerprint,
            operationTableFingerprint);

        return new ModuleState(
            source,
            sourceFingerprint,
            abi,
            Array.AsReadOnly(contracts),
            contractsByIdentity,
            Array.AsReadOnly(identities));
    }

    private static int OffsetOf<T>(string fieldName) where T : struct =>
        Marshal.OffsetOf<T>(fieldName).ToInt32();

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
        builder.Append('\n').Append(
            DeviceDispatchCudaBlockCatalog.KernelSource
                .Replace("\r\n", "\n", StringComparison.Ordinal)
                .Replace('\r', '\n'));
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
        deviceSource = CanonicalizePublishedLineEndings(deviceSource, entryPoint);
        builder.Append(deviceSource).Append('\n');
    }

    private static string CanonicalizePublishedLineEndings(string source, string entryPoint)
    {
        var builder = new StringBuilder(source.Length);
        var newlineIndex = 0;
        for (var index = 0; index < source.Length; index++)
        {
            var character = source[index];
            if (character == '\r')
            {
                if (index + 1 < source.Length && source[index + 1] == '\n')
                    index++;
                AppendPublishedNewline(builder, entryPoint, ++newlineIndex);
                continue;
            }

            if (character == '\n')
            {
                AppendPublishedNewline(builder, entryPoint, ++newlineIndex);
                continue;
            }

            builder.Append(character);
        }

        return builder.ToString();
    }

    private static void AppendPublishedNewline(
        StringBuilder builder,
        string entryPoint,
        int newlineIndex)
    {
        if (IsPublishedLfOnlyLine(entryPoint, newlineIndex))
            builder.Append('\n');
        else
            builder.Append("\r\n");
    }

    private static bool IsPublishedLfOnlyLine(string entryPoint, int newlineIndex) =>
        entryPoint switch
        {
            "mathblocks_scalar" => newlineIndex == 474,
            "mathblocks_vector" =>
                IsInRange(newlineIndex, 82, 92) ||
                IsInRange(newlineIndex, 609, 642) ||
                newlineIndex == 676,
            "mathblocks_complex" => newlineIndex == 340,
            "mathblocks_matrix" => newlineIndex == 1238,
            "mathblocks_probability" => newlineIndex == 657,
            "mathblocks_sequence_path" =>
                IsInRange(newlineIndex, 13, 23) ||
                IsInRange(newlineIndex, 29, 39) ||
                IsInRange(newlineIndex, 41, 361) ||
                IsInRange(newlineIndex, 529, 793) ||
                IsInRange(newlineIndex, 1133, 1141) ||
                IsInRange(newlineIndex, 1145, 1153) ||
                newlineIndex == 1299,
            "mathblocks_statistics" => newlineIndex == 537,
            "mathblocks_geometry" =>
                IsInRange(newlineIndex, 382, 390) ||
                IsInRange(newlineIndex, 467, 474) ||
                IsInRange(newlineIndex, 480, 483) ||
                IsInRange(newlineIndex, 589, 596) ||
                IsInRange(newlineIndex, 602, 605) ||
                IsInRange(newlineIndex, 768, 778) ||
                newlineIndex == 862,
            "mathblocks_graph" =>
                IsInRange(newlineIndex, 240, 247) ||
                IsInRange(newlineIndex, 252, 255) ||
                newlineIndex == 560,
            "mathblocks_advanced" => newlineIndex == 546,
            "mathblocks_transport" =>
                IsInRange(newlineIndex, 386, 387),
            _ => throw new InvalidOperationException(
                $"CUDA line-ending authority is missing for '{entryPoint}'.")
        };

    private static bool IsInRange(int value, int minimum, int maximum) =>
        value >= minimum && value <= maximum;

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


    private sealed record ModuleState(
        string Source,
        string SourceFingerprint,
        MathBlockCudaDeviceAbi Abi,
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

    public static string CreateImplementation(Type type)
    {
        ArgumentNullException.ThrowIfNull(type);
        var reflectedMethods = type.GetMethods(
            BindingFlags.Public |
            BindingFlags.NonPublic |
            BindingFlags.Static |
            BindingFlags.DeclaredOnly);
        var methods = new List<MethodBase>(reflectedMethods.Length + 1);
        foreach (var method in reflectedMethods)
            methods.Add(method);
        if (type.TypeInitializer is not null)
            methods.Add(type.TypeInitializer);
        methods.Sort((left, right) => StringComparer.Ordinal.Compare(
            CreateMethodIdentity(left),
            CreateMethodIdentity(right)));

        var material = new StringBuilder("mathblocks-managed-implementation-v1\n")
            .Append(type.FullName).Append('\n');
        foreach (var method in methods)
        {
            material.Append(CreateMethodIdentity(method)).Append('\n');
            var body = method.GetMethodBody();
            if (body is null)
            {
                material.Append("body:none\n");
                continue;
            }

            material.Append(body.InitLocals ? "init-locals:1\n" : "init-locals:0\n")
                .Append("max-stack:")
                .Append(body.MaxStackSize.ToString(CultureInfo.InvariantCulture))
                .Append('\n');
            foreach (var local in body.LocalVariables)
            {
                material.Append("local:")
                    .Append(local.LocalIndex.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(local.LocalType.AssemblyQualifiedName).Append(':')
                    .Append(local.IsPinned ? '1' : '0').Append('\n');
            }
            foreach (var clause in body.ExceptionHandlingClauses)
            {
                material.Append("clause:")
                    .Append(((int)clause.Flags).ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.TryOffset.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.TryLength.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.HandlerOffset.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.HandlerLength.ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append((clause.Flags == ExceptionHandlingClauseOptions.Filter
                        ? clause.FilterOffset
                        : -1).ToString(CultureInfo.InvariantCulture)).Append(':')
                    .Append(clause.Flags == ExceptionHandlingClauseOptions.Clause
                        ? clause.CatchType?.AssemblyQualifiedName
                        : null).Append('\n');
            }
            material.Append("il:")
                .Append(Convert.ToHexString(body.GetILAsByteArray() ?? []))
                .Append('\n');
        }
        return Create(material.ToString());
    }

    private static string CreateMethodIdentity(MethodBase method)
    {
        var identity = new StringBuilder(method.Name).Append('(');
        var parameters = method.GetParameters();
        for (var index = 0; index < parameters.Length; index++)
        {
            if (index != 0)
                identity.Append(',');
            identity.Append(parameters[index].ParameterType.AssemblyQualifiedName);
        }
        identity.Append(')');
        if (method is MethodInfo methodInfo)
            identity.Append("->").Append(methodInfo.ReturnType.AssemblyQualifiedName);
        return identity.ToString();
    }
}
