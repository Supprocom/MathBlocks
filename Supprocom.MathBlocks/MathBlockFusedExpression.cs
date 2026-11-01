using System.Security.Cryptography;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks;

/// <summary>Evaluates a program of pointwise operations row by row, on CoreCLR or inside a consumer's CUDA kernel.</summary>
/// <remarks>
/// <para>
/// The program's inputs are vectors of one common length (Vector or BooleanVector) and scalars. Every operation
/// node is a pointwise Standard operation, so output row t is a function of input row t only. The fused forms
/// evaluate all nodes for one row before the next row, with no intermediate vectors.
/// </para>
/// <para>
/// The outputs equal the unfused program's outputs, including invalid state and reason. An operation node that
/// produces a nonfinite value in any row sets its bit in a 64-bit invalid mask, and the outputs are rebuilt from
/// that mask by walking the program in node order: a node with an invalid input takes the first invalid input's
/// reason, and a node whose own bit is set takes its operation's nonfinite reason.
/// </para>
/// </remarks>
public sealed class MathBlockFusedExpression
{
    /// <summary>Gets the largest number of operation nodes, one per invalid-mask bit.</summary>
    public const int MaximumOperationNodes = 64;
    /// <summary>Gets the largest number of vector inputs (Vector or BooleanVector).</summary>
    public const int MaximumVectorInputs = 16;
    /// <summary>Gets the largest number of outputs.</summary>
    public const int MaximumOutputs = 4;

    private const string FingerprintFormat = "mathblocks-fused-expression-v1";
    private const int RowBlock = 8192;

    private readonly MathBlockProgram program;
    private readonly Step[] steps;
    private readonly int[] vectorInputNodes;
    private readonly int[] scalarNodes;
    private readonly int[] outputNodes;
    private readonly int[] maskBits;
    private readonly int[] contributingInputs;
    private readonly MathBlockFusedKind[] kinds;
    private readonly Lazy<string> cudaSource;

    private MathBlockFusedExpression(
        MathBlockProgram program,
        Step[] steps,
        int[] vectorInputNodes,
        int[] scalarNodes,
        int[] outputNodes,
        int[] maskBits,
        int[] contributingInputs,
        MathBlockFusedKind[] kinds)
    {
        this.program = program;
        this.steps = steps;
        this.vectorInputNodes = vectorInputNodes;
        this.scalarNodes = scalarNodes;
        this.outputNodes = outputNodes;
        this.maskBits = maskBits;
        this.contributingInputs = contributingInputs;
        this.kinds = kinds;

        Fingerprint = CreateFingerprint(program.Fingerprint, MathBlockCudaDeviceModule.SourceFingerprint);
        CudaFunctionName = "mathblocks_fused_" + Fingerprint;
        CudaKernelName = CudaFunctionName + "_kernel";
        VectorInputNames = Array.AsReadOnly(MathBlockCollectionPrimitives.Map(
            vectorInputNodes, node => program.Nodes[node].Name!));
        var scalarInputs = new List<string>();
        foreach (var node in scalarNodes)
            if (program.Nodes[node].Kind == MathBlockProgramBuilder.NodeKind.Input)
                scalarInputs.Add(program.Nodes[node].Name!);
        ScalarInputNames = scalarInputs.AsReadOnly();
        OutputNames = Array.AsReadOnly(MathBlockCollectionPrimitives.MapIndexed(
            outputNodes, (_, index) => program.GetOutputName(index)));
        MaskNodeIndexes = Array.AsReadOnly(MathBlockCollectionPrimitives.Map(steps, step => step.Node));
        cudaSource = new Lazy<string>(() => MathBlockFusedCudaSource.Create(this));
    }

    /// <summary>Gets the fused program.</summary>
    public MathBlockProgram Program => program;

    /// <summary>Gets the lowercase hexadecimal SHA-256 fingerprint of the fused expression.</summary>
    /// <remarks>
    /// The material is <c>mathblocks-fused-expression-v1</c>, the program fingerprint and the MathBlocks CUDA source
    /// fingerprint (<see cref="MathBlockCudaDeviceModule.SourceFingerprint"/>), each ended by a line feed, as UTF-8.
    /// </remarks>
    public string Fingerprint { get; }

    /// <summary>Gets the vector input names in CUDA <c>inputs</c> and <c>validity</c> order (program node order).</summary>
    public IReadOnlyList<string> VectorInputNames { get; }

    /// <summary>Gets the scalar input names in CUDA <c>scalars</c> order (program node order).</summary>
    public IReadOnlyList<string> ScalarInputNames { get; }

    /// <summary>Gets the output names in CUDA <c>outputs</c> and <c>output_validity</c> order (program output order).</summary>
    public IReadOnlyList<string> OutputNames { get; }

    /// <summary>Gets the program node index of each invalid-mask bit, from bit 0 upward.</summary>
    public IReadOnlyList<int> MaskNodeIndexes { get; }

    /// <summary>Gets the name of the per-row CUDA device function in <see cref="CudaSource"/>.</summary>
    public string CudaFunctionName { get; }

    /// <summary>Gets the name of the ready-made CUDA kernel in <see cref="CudaSource"/>.</summary>
    public string CudaKernelName { get; }

    /// <summary>Gets the CUDA source of the per-row device function and its kernel.</summary>
    /// <remarks>
    /// The source calls MathBlocks device functions, so it is compiled after
    /// <see cref="MathBlockCudaDeviceModule.Source"/>, for example through
    /// <see cref="MathBlockCudaDeviceModule.ComposeSource(string)"/>. Inline arithmetic uses explicit rounding
    /// intrinsics, so the row values do not depend on the compiler's contraction setting.
    /// </remarks>
    public string CudaSource => cudaSource.Value;

    internal Step[] Steps => steps;
    internal int[] VectorInputNodes => vectorInputNodes;
    internal int[] ScalarNodes => scalarNodes;
    internal int[] OutputNodes => outputNodes;
    internal MathBlockFusedKind[] Kinds => kinds;

    // The mask bit of an operation node, or -1 for other nodes.
    internal int MaskBit(int node) => maskBits[node];

    // The vector inputs (by ordinal) that reach a node, as a bit set.
    internal int ContributingInputs(int node) => contributingInputs[node];

    /// <summary>Checks that a program can be fused and prepares its fused forms.</summary>
    /// <exception cref="ArgumentNullException"><paramref name="program"/> is null.</exception>
    /// <exception cref="ArgumentException">
    /// A node is not a pointwise Standard operation, an input or constant of a supported kind, or a limit is exceeded.
    /// The message names the node or the limit.
    /// </exception>
    public static MathBlockFusedExpression Create(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);
        var nodes = program.Nodes;
        var nodeKinds = new MathBlockFusedKind[nodes.Length];
        var nodeBits = new int[nodes.Length];
        var contributing = new int[nodes.Length];
        var operationSteps = new List<Step>();
        var vectorInputs = new List<int>();
        var scalars = new List<int>();
        for (var index = 0; index < nodes.Length; index++)
        {
            var node = nodes[index];
            nodeBits[index] = -1;
            switch (node.Kind)
            {
                case MathBlockProgramBuilder.NodeKind.Input:
                    nodeKinds[index] = node.Type.Kind switch
                    {
                        MathBlockValueKind.Vector => MathBlockFusedKind.Number,
                        MathBlockValueKind.BooleanVector => MathBlockFusedKind.Flag,
                        MathBlockValueKind.Scalar => MathBlockFusedKind.Scalar,
                        _ => throw new ArgumentException(
                            $"Input '{node.Name}' (node {index}) has kind {node.Type.Kind}; a fused expression " +
                            "takes Vector, BooleanVector and Scalar inputs.",
                            nameof(program))
                    };
                    if (nodeKinds[index] == MathBlockFusedKind.Scalar)
                    {
                        scalars.Add(index);
                    }
                    else
                    {
                        if (vectorInputs.Count == MaximumVectorInputs)
                            throw new ArgumentException(
                                $"Input '{node.Name}' (node {index}) exceeds the limit of {MaximumVectorInputs} " +
                                "vector inputs of a fused expression.",
                                nameof(program));
                        contributing[index] = 1 << vectorInputs.Count;
                        vectorInputs.Add(index);
                    }
                    break;
                case MathBlockProgramBuilder.NodeKind.Constant:
                    if (node.Type.Kind != MathBlockValueKind.Scalar)
                        throw new ArgumentException(
                            $"Constant node {index} has kind {node.Type.Kind}; a fused expression takes scalar " +
                            "constants only. Pass a vector as an input.",
                            nameof(program));
                    nodeKinds[index] = MathBlockFusedKind.Scalar;
                    scalars.Add(index);
                    break;
                case MathBlockProgramBuilder.NodeKind.Operation:
                    var step = CreateStep(program, index, nodeKinds);
                    if (operationSteps.Count == MaximumOperationNodes)
                        throw new ArgumentException(
                            $"Operation node {index} ({step.Operation.Identity}) exceeds the limit of " +
                            $"{MaximumOperationNodes} operation nodes of a fused expression.",
                            nameof(program));
                    nodeBits[index] = operationSteps.Count;
                    nodeKinds[index] = step.Operation.Result;
                    foreach (var argument in node.Inputs)
                        contributing[index] |= contributing[argument];
                    operationSteps.Add(step);
                    break;
                default:
                    throw new ArgumentException($"Node {index} has an unsupported kind.", nameof(program));
            }
        }

        if (program.OutputCount > MaximumOutputs)
            throw new ArgumentException(
                $"The program has {program.OutputCount} outputs; a fused expression has at most {MaximumOutputs}.",
                nameof(program));
        var outputs = new int[program.OutputCount];
        for (var index = 0; index < outputs.Length; index++)
        {
            var node = program.GetOutputNodeIndex(index);
            if (nodeKinds[node] is not (MathBlockFusedKind.Number or MathBlockFusedKind.Flag))
                throw new ArgumentException(
                    $"Output '{program.GetOutputName(index)}' (node {node}) has kind {nodes[node].Type.Kind}; " +
                    "a fused expression outputs Vector and BooleanVector values.",
                    nameof(program));
            outputs[index] = node;
        }

        return new MathBlockFusedExpression(
            program,
            [.. operationSteps],
            [.. vectorInputs],
            [.. scalars],
            outputs,
            nodeBits,
            contributing,
            nodeKinds);
    }

    /// <summary>Evaluates the fused expression on CoreCLR, one row at a time.</summary>
    /// <param name="inputs">The program inputs by name. Vector inputs that are valid have one common length.</param>
    /// <param name="validity">
    /// Optional BooleanVector validity inputs, keyed by vector input name, each as long as the vector inputs.
    /// </param>
    /// <returns>The outputs, equal to the unfused program's outputs, with each output's row validity.</returns>
    /// <exception cref="ArgumentException">Vector input lengths differ, or a validity input does not fit.</exception>
    public MathBlockFusedResult EvaluateCoreCLR(
        IReadOnlyDictionary<string, MathBlockValue> inputs,
        IReadOnlyDictionary<string, MathBlockValue>? validity = null)
    {
        var values = program.CreateValueBuffer(inputs);
        var rows = ResolveRows(values);
        var validityValues = ResolveValidity(validity, rows);
        var columns = new Array[outputNodes.Length];
        var validityColumns = new bool[outputNodes.Length][];
        var mask = EvaluateRows(values, validityValues, rows, columns, validityColumns);
        return CreateResult(values, validityValues, rows, columns, validityColumns, mask);
    }

    /// <summary>Rebuilds the outputs of a CUDA launch of <see cref="CudaKernelName"/>.</summary>
    /// <param name="inputs">The program inputs the launch used.</param>
    /// <param name="validity">The validity inputs the launch used, or null.</param>
    /// <param name="outputs">
    /// Each output's rows in <see cref="OutputNames"/> order: a <see cref="double"/> array for a Vector output and an
    /// <see cref="int"/> array of 0 and 1 for a BooleanVector output.
    /// </param>
    /// <param name="validityOutputs">Each output's row validity (0 or 1), in <see cref="OutputNames"/> order.</param>
    /// <param name="invalidMask">The launch's invalid mask, which started at zero.</param>
    /// <returns>The outputs, equal to the unfused program's outputs, with each output's row validity.</returns>
    /// <exception cref="ArgumentException">An array does not match its output, or the inputs do not fit.</exception>
    public MathBlockFusedResult CreateCudaResult(
        IReadOnlyDictionary<string, MathBlockValue> inputs,
        IReadOnlyDictionary<string, MathBlockValue>? validity,
        IReadOnlyList<Array> outputs,
        IReadOnlyList<int[]> validityOutputs,
        ulong invalidMask)
    {
        ArgumentNullException.ThrowIfNull(outputs);
        ArgumentNullException.ThrowIfNull(validityOutputs);
        var values = program.CreateValueBuffer(inputs);
        var rows = ResolveRows(values);
        var validityValues = ResolveValidity(validity, rows);
        if (outputs.Count != outputNodes.Length || validityOutputs.Count != outputNodes.Length)
            throw new ArgumentException($"The fused expression has {outputNodes.Length} outputs.", nameof(outputs));
        var columns = new Array[outputNodes.Length];
        var validityColumns = new bool[outputNodes.Length][];
        for (var index = 0; index < outputNodes.Length; index++)
        {
            var name = OutputNames[index];
            columns[index] = kinds[outputNodes[index]] == MathBlockFusedKind.Number
                ? outputs[index] is double[] numbers && numbers.Length == rows
                    ? MathBlockCollectionPrimitives.Copy(numbers)
                    : throw new ArgumentException($"Output '{name}' requires {rows} double values.", nameof(outputs))
                : outputs[index] is int[] flags && flags.Length == rows
                    ? MathBlockCollectionPrimitives.Map(flags, flag => flag != 0)
                    : throw new ArgumentException($"Output '{name}' requires {rows} int values.", nameof(outputs));
            validityColumns[index] = validityOutputs[index] is { } rowValidity && rowValidity.Length == rows
                ? MathBlockCollectionPrimitives.Map(rowValidity, flag => flag != 0)
                : throw new ArgumentException(
                    $"The validity of output '{name}' requires {rows} int values.", nameof(validityOutputs));
        }
        return CreateResult(values, validityValues, rows, columns, validityColumns, invalidMask);
    }

    internal static string CreateFingerprint(string programFingerprint, string sourceFingerprint)
    {
        var material = FingerprintFormat + "\n" + programFingerprint + "\n" + sourceFingerprint + "\n";
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(material));
        return Convert.ToHexStringLower(hash);
    }

    private static Step CreateStep(MathBlockProgram program, int index, MathBlockFusedKind[] kinds)
    {
        var node = program.Nodes[index];
        var operation = node.Operation!;
        var identity = operation.Identity;
        MathBlockCausality causality;
        try
        {
            causality = operation.Causality.Kind;
        }
        catch (InvalidOperationException exception)
        {
            throw new ArgumentException($"Operation node {index} ({identity}) has no causality label.", nameof(program), exception);
        }
        if (causality != MathBlockCausality.Pointwise)
            throw new ArgumentException(
                $"Operation node {index} ({identity}) is {causality}; a fused expression accepts only Pointwise " +
                "operations.",
                nameof(program));
        if (MathBlockFusedOperations.Excluded.TryGetValue(identity, out var reason))
            throw new ArgumentException(
                $"Operation node {index} ({identity}) is Pointwise, but {reason}, so it cannot be fused.",
                nameof(program));
        if (!MathBlockFusedOperations.TryResolve(identity, out var fused))
            throw new ArgumentException(
                $"Operation node {index} ({identity}) has no fused row form.", nameof(program));
        if (!TryGetStandard(operation, out var standard) || !ReferenceEquals(standard, operation))
            throw new ArgumentException(
                $"Operation node {index} ({identity}) is not the MathBlockCatalog.Standard operation.",
                nameof(program));
        for (var argument = 0; argument < node.Inputs.Length; argument++)
            if (kinds[node.Inputs[argument]] != fused.Arguments[argument])
                throw new ArgumentException(
                    $"Operation node {index} ({identity}) input {argument} (node {node.Inputs[argument]}) has " +
                    $"kind {program.Nodes[node.Inputs[argument]].Type.Kind}, which its fused row form does not take.",
                    nameof(program));
        return new Step(index, fused, MathBlockCollectionPrimitives.Copy(node.Inputs));
    }

    private static bool TryGetStandard(MathBlockOperation operation, out MathBlockOperation standard)
    {
        try
        {
            standard = MathBlockCatalog.Standard.Get(operation.Identifier, operation.Version);
            return true;
        }
        catch (KeyNotFoundException)
        {
            standard = operation;
            return false;
        }
    }

    // The common row count of the valid vector inputs. Invalid inputs carry no rows; when every vector input is
    // invalid, every output is invalid and there are no rows to evaluate.
    private int ResolveRows(MathBlockValue[] values)
    {
        var rows = -1;
        foreach (var node in vectorInputNodes)
        {
            var value = values[node];
            if (!value.IsValid)
                continue;
            var count = value.Type.Kind == MathBlockValueKind.Vector
                ? value.AsVector().Count
                : value.AsBooleanVector().Count;
            if (rows < 0)
                rows = count;
            else if (count != rows)
                throw new ArgumentException(
                    $"Vector input '{program.Nodes[node].Name}' has {count} rows; the fused expression's vector " +
                    $"inputs have {rows}.",
                    nameof(values));
        }
        return Math.Max(rows, 0);
    }

    private MathBlockValue?[] ResolveValidity(IReadOnlyDictionary<string, MathBlockValue>? validity, int rows)
    {
        var result = new MathBlockValue?[vectorInputNodes.Length];
        if (validity is null)
            return result;
        var matched = 0;
        for (var ordinal = 0; ordinal < vectorInputNodes.Length; ordinal++)
        {
            var name = VectorInputNames[ordinal];
            if (!validity.TryGetValue(name, out var value))
                continue;
            matched++;
            if (value.Type.Kind != MathBlockValueKind.BooleanVector)
                throw new ArgumentException(
                    $"The validity input of '{name}' has kind {value.Type.Kind}; it must be a BooleanVector.",
                    nameof(validity));
            if (value.IsValid && value.AsBooleanVector().Count != rows)
                throw new ArgumentException(
                    $"The validity input of '{name}' has {value.AsBooleanVector().Count} rows; the vector inputs " +
                    $"have {rows}.",
                    nameof(validity));
            result[ordinal] = value;
        }
        if (matched != validity.Count)
        {
            var names = new HashSet<string>(VectorInputNames, StringComparer.Ordinal);
            foreach (var name in validity.Keys)
                if (!names.Contains(name))
                    throw new ArgumentException(
                        $"The validity input '{name}' does not name a vector input of the fused expression.",
                        nameof(validity));
        }
        return result;
    }

    private ulong EvaluateRows(
        MathBlockValue[] values,
        MathBlockValue?[] validity,
        int rows,
        Array[] columns,
        bool[][] validityColumns)
    {
        // Invalid inputs and validity inputs carry no rows; their registers keep zero (false) and their row
        // validity true. Every node they reach is invalid in the rebuilt result, so those row values are unused.
        var source = new RowSource(vectorInputNodes.Length);
        for (var ordinal = 0; ordinal < vectorInputNodes.Length; ordinal++)
        {
            var value = values[vectorInputNodes[ordinal]];
            if (value.IsValid && value.Type.Kind == MathBlockValueKind.Vector)
                source.Vectors[ordinal] = value.AsVector();
            else if (value.IsValid)
                source.Booleans[ordinal] = value.AsBooleanVector();
            if (validity[ordinal] is { IsValid: true } rowValidity)
                source.Validity[ordinal] = rowValidity.AsBooleanVector();
        }

        for (var index = 0; index < outputNodes.Length; index++)
        {
            columns[index] = kinds[outputNodes[index]] == MathBlockFusedKind.Number ? new double[rows] : new bool[rows];
            validityColumns[index] = new bool[rows];
        }

        // Rows are independent, so blocks of rows run in parallel; each row's arithmetic is the same in any order,
        // and the invalid mask is an OR over all rows.
        var mask = 0ul;
        var blocks = (rows + RowBlock - 1) / RowBlock;
        Parallel.For(0, blocks, block =>
        {
            var blockMask = EvaluateBlock(
                values, source, block * RowBlock, Math.Min(rows, (block + 1) * RowBlock), columns, validityColumns);
            if (blockMask != 0)
                Interlocked.Or(ref mask, blockMask);
        });
        return mask;
    }

    private ulong EvaluateBlock(
        MathBlockValue[] values,
        RowSource source,
        int start,
        int end,
        Array[] columns,
        bool[][] validityColumns)
    {
        var count = values.Length;
        var number = new double[count];
        var flag = new bool[count];
        var complex = new Complex[count];
        var rowValid = new bool[count];
        foreach (var node in scalarNodes)
        {
            number[node] = values[node].IsValid ? values[node].AsScalar() : 0d;
            rowValid[node] = true;
        }
        foreach (var node in vectorInputNodes)
            rowValid[node] = true;

        var mask = 0ul;
        for (var row = start; row < end; row++)
        {
            for (var ordinal = 0; ordinal < vectorInputNodes.Length; ordinal++)
            {
                var node = vectorInputNodes[ordinal];
                if (source.Vectors[ordinal] is { } vector)
                    number[node] = vector[row];
                else if (source.Booleans[ordinal] is { } boolean)
                    flag[node] = boolean[row];
                if (source.Validity[ordinal] is { } rowValidity)
                    rowValid[node] = rowValidity[row];
            }

            for (var stepIndex = 0; stepIndex < steps.Length; stepIndex++)
            {
                if (!EvaluateStep(steps[stepIndex], number, flag, complex, rowValid))
                    mask |= 1ul << stepIndex;
            }

            for (var index = 0; index < outputNodes.Length; index++)
            {
                var node = outputNodes[index];
                if (columns[index] is double[] numbers)
                    numbers[row] = number[node];
                else
                    ((bool[])columns[index])[row] = flag[node];
                validityColumns[index][row] = rowValid[node];
            }
        }
        return mask;
    }

    // Evaluates one operation node for the current row and returns whether its value is finite.
    private static bool EvaluateStep(Step step, double[] number, bool[] flag, Complex[] complex, bool[] rowValid)
    {
        var arguments = step.Arguments;
        var node = step.Node;
        var opcode = step.Operation.Opcode;
        var finite = true;
        switch (step.Operation.Result)
        {
            case MathBlockFusedKind.Number:
                if (opcode == MathBlockFusedOpcode.VectorSelect)
                    number[node] = flag[arguments[0]] ? number[arguments[1]] : number[arguments[2]];
                else if (step.Operation.Arguments[0] == MathBlockFusedKind.Complex)
                    number[node] = MathBlockFusedOperations.EvaluateProjection(opcode, complex[arguments[0]]);
                else
                    number[node] = MathBlockFusedOperations.EvaluateNumber(
                        opcode,
                        number[arguments[0]],
                        arguments.Length > 1 ? number[arguments[1]] : 0d);
                finite = Math.IsFinite(number[node]);
                break;
            case MathBlockFusedKind.Flag:
                flag[node] = step.Operation.Arguments[0] == MathBlockFusedKind.Flag
                    ? MathBlockFusedOperations.EvaluateLogic(
                        opcode,
                        flag[arguments[0]],
                        arguments.Length > 1 && flag[arguments[1]])
                    : MathBlockFusedOperations.EvaluateFlag(opcode, number[arguments[0]], number[arguments[1]]);
                break;
            case MathBlockFusedKind.Complex:
                complex[node] = new Complex(number[arguments[0]], number[arguments[1]]);
                finite = Math.IsFinite(complex[node].Real) && Math.IsFinite(complex[node].Imaginary);
                break;
        }

        var valid = true;
        foreach (var argument in arguments)
            valid &= rowValid[argument];
        rowValid[node] = valid;
        return finite;
    }

    // Walks the program in node order, as the unfused evaluation does, to give each node its type and invalid
    // state, then wraps the output rows.
    private MathBlockFusedResult CreateResult(
        MathBlockValue[] values,
        MathBlockValue?[] validity,
        int rows,
        Array[] columns,
        bool[][] validityColumns,
        ulong mask)
    {
        var nodes = program.Nodes;
        var types = new MathBlockType[nodes.Length];
        var reasons = new string?[nodes.Length];
        var valid = new bool[nodes.Length];
        for (var index = 0; index < nodes.Length; index++)
        {
            var node = nodes[index];
            if (node.Kind != MathBlockProgramBuilder.NodeKind.Operation)
            {
                types[index] = values[index].Type;
                valid[index] = values[index].IsValid;
                reasons[index] = values[index].InvalidReason;
                continue;
            }

            var argumentTypes = new MathBlockType[node.Inputs.Length];
            var firstInvalid = -1;
            for (var argument = 0; argument < node.Inputs.Length; argument++)
            {
                argumentTypes[argument] = types[node.Inputs[argument]];
                if (firstInvalid < 0 && !valid[node.Inputs[argument]])
                    firstInvalid = node.Inputs[argument];
            }
            var resolved = node.Operation!.ResolveOutputType(argumentTypes);
            if (firstInvalid >= 0)
            {
                types[index] = resolved;
                reasons[index] = reasons[firstInvalid] ?? "An input value is invalid.";
                continue;
            }
            types[index] = kinds[index] switch
            {
                MathBlockFusedKind.Number => MathBlockType.Vector(resolved.Unit, rows),
                MathBlockFusedKind.Flag => MathBlockType.BooleanVector(rows),
                _ => MathBlockType.ComplexVector(resolved.Unit, rows)
            };
            if ((mask & (1ul << maskBits[index])) != 0)
            {
                reasons[index] = kinds[index] == MathBlockFusedKind.Complex
                    ? "The complex vector result contains a nonfinite value."
                    : "The vector result contains a nonfinite value.";
                continue;
            }
            valid[index] = true;
        }

        var outputs = new Dictionary<string, MathBlockValue>(outputNodes.Length, StringComparer.Ordinal);
        var validityOutputs = new Dictionary<string, MathBlockValue>(outputNodes.Length, StringComparer.Ordinal);
        for (var index = 0; index < outputNodes.Length; index++)
        {
            var node = outputNodes[index];
            MathBlockValue output;
            if (nodes[node].Kind != MathBlockProgramBuilder.NodeKind.Operation)
                output = values[node];
            else if (!valid[node])
                output = program.PlannedOutput(node, MathBlockValue.Invalid(types[node], reasons[node]!));
            else if (columns[index] is double[] numbers)
                output = MathBlockValue.Vector(numbers, types[node].Unit, true);
            else
                output = MathBlockValue.BooleanVector((bool[])columns[index], true);
            outputs.Add(OutputNames[index], output);
            validityOutputs.Add(OutputNames[index], CreateValidity(node, validity, rows, validityColumns[index]));
        }
        return new MathBlockFusedResult(outputs, validityOutputs, mask);
    }

    // An output's row validity combines the validity inputs of the vector inputs that reach it. An invalid
    // validity input makes the combination invalid with that input's reason, taking inputs in node order.
    private MathBlockValue CreateValidity(int node, MathBlockValue?[] validity, int rows, bool[] rowValidity)
    {
        var reached = contributingInputs[node];
        for (var ordinal = 0; ordinal < vectorInputNodes.Length; ordinal++)
            if ((reached & (1 << ordinal)) != 0 && validity[ordinal] is { IsValid: false } invalid)
                return MathBlockValue.Invalid(
                    MathBlockType.BooleanVector(rows),
                    invalid.InvalidReason ?? "An input value is invalid.");
        return MathBlockValue.BooleanVector(rowValidity, true);
    }

    private sealed class RowSource
    {
        public RowSource(int count)
        {
            Vectors = new MathBlockVector?[count];
            Booleans = new MathBlockBooleanVector?[count];
            Validity = new MathBlockBooleanVector?[count];
        }

        public MathBlockVector?[] Vectors { get; }
        public MathBlockBooleanVector?[] Booleans { get; }
        public MathBlockBooleanVector?[] Validity { get; }
    }

    internal sealed class Step
    {
        public Step(int node, MathBlockFusedOperation operation, int[] arguments)
        {
            Node = node;
            Operation = operation;
            Arguments = arguments;
        }

        public int Node { get; }
        public MathBlockFusedOperation Operation { get; }
        public int[] Arguments { get; }
    }
}
