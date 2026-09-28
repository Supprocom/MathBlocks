using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Operation Contract contract.</summary>
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

    /// <summary>Gets the identifier value.</summary>
    public string Identifier => operation.Identifier;
    /// <summary>Gets the version value.</summary>
    public int Version => operation.Version;
    /// <summary>Gets the arity value.</summary>
    public int Arity => operation.Arity;
    /// <summary>Gets the identity value.</summary>
    public string Identity => operation.Identity;
    /// <summary>Gets the family value.</summary>
    public MathBlockCudaOperationFamily Family { get; }
    /// <summary>Gets the opcode value.</summary>
    public int Opcode { get; }
    /// <summary>Gets the required block size value.</summary>
    public int RequiredBlockSize => MathBlockCudaDeviceModule.DispatcherBlockSize;
    /// <summary>Gets the native block size value.</summary>
    public uint NativeBlockSize { get; }
    /// <summary>Gets the execution behavior value.</summary>
    public MathBlockCudaExecutionBehavior ExecutionBehavior { get; }
    /// <summary>Gets the operand type rule value.</summary>
    public string OperandTypeRule { get; }
    /// <summary>Gets the output type rule value.</summary>
    public string OutputTypeRule { get; }
    /// <summary>Gets the unit rule value.</summary>
    public string UnitRule { get; }
    /// <summary>Gets the shape rule value.</summary>
    public string ShapeRule { get; }
    /// <summary>Gets the capacity rule value.</summary>
    public string CapacityRule { get; }
    /// <summary>Gets the scratch rule value.</summary>
    public string ScratchRule { get; }
    /// <summary>Gets the validity rule value.</summary>
    public string ValidityRule { get; }
    /// <summary>Gets the execution rule value.</summary>
    public string ExecutionRule { get; }
    /// <summary>Gets the performance evidence fingerprint value.</summary>
    public string PerformanceEvidenceFingerprint { get; }
    /// <summary>Gets the fingerprint value.</summary>
    public string Fingerprint { get; }
    /// <summary>Gets the regression cases value.</summary>
    public IReadOnlyList<MathBlockRegressionCase> RegressionCases => operation.RegressionCases;
    /// <summary>Gets the performance case value.</summary>
    public MathBlockPerformanceCase PerformanceCase => operation.PerformanceCase;

    /// <summary>Gets the regression cases for this CUDA operation contract.</summary>
    // Retain the published method shape for binary and source compatibility.
#pragma warning disable CA1024
    public IReadOnlyList<MathBlockCudaContractCase> GetContractCases()
    {
        return contractCases;
    }
#pragma warning restore CA1024

    /// <summary>Resolves the output type using the shared CPU/CUDA type contract.</summary>
    public MathBlockType ResolveOutputType(IReadOnlyList<MathBlockType> inputTypes) =>
        operation.ResolveOutputType(inputTypes);

    /// <summary>Evaluates the operation on the CPU with positional values.</summary>
    public MathBlockValue EvaluateCPU(params MathBlockValue[] inputs) =>
        operation.Evaluate(inputs);

    /// <summary>Evaluates the operation on the CPU with a read-only input list.</summary>
    public MathBlockValue EvaluateCPU(IReadOnlyList<MathBlockValue> inputs) =>
        operation.Evaluate(inputs);

    /// <summary>Plans CUDA shape, capacity, and scratch storage for inputs.</summary>
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
