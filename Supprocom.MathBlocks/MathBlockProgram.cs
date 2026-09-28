using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Program contract.</summary>
public sealed class MathBlockProgram
{
    private readonly Node[] nodes;
    private readonly int[][] operationLevels;
    private readonly Output[] outputs;
    private readonly IReadOnlyList<MathBlockProgramNode> planNodes;
    private readonly Dictionary<string, MathBlockType> inputTypes;
    private readonly Dictionary<string, MathBlockType> outputTypes;
    private readonly Dictionary<string, int> outputNodeIndexes;

    internal MathBlockProgram(
        IReadOnlyList<MathBlockProgramBuilder.NodeDefinition> definitions,
        IReadOnlyList<(string Name, int Node)> outputDefinitions)
    {
        nodes = MathBlockCollectionPrimitives.Map(definitions, definition => new Node(definition));
        outputs = MathBlockCollectionPrimitives.Map(
            outputDefinitions,
            output => new Output(output.Name, output.Node));
        planNodes = Array.AsReadOnly(MathBlockCollectionPrimitives.MapIndexed(
            nodes,
            (node, index) => new MathBlockProgramNode(index, node)));

        var discoveredInputs = new Dictionary<string, MathBlockType>(StringComparer.Ordinal);
        for (var index = 0; index < nodes.Length; index++)
        {
            var node = nodes[index];
            if (node.Kind == MathBlockProgramBuilder.NodeKind.Input)
                discoveredInputs.Add(node.Name!, node.Type);
        }
        inputTypes = discoveredInputs;

        var discoveredOutputTypes = new Dictionary<string, MathBlockType>(StringComparer.Ordinal);
        var discoveredOutputNodes = new Dictionary<string, int>(StringComparer.Ordinal);
        for (var index = 0; index < outputs.Length; index++)
        {
            var output = outputs[index];
            discoveredOutputTypes.Add(output.Name, nodes[output.NodeIndex].Type);
            discoveredOutputNodes.Add(output.Name, output.NodeIndex);
        }
        outputTypes = discoveredOutputTypes;
        outputNodeIndexes = discoveredOutputNodes;
        operationLevels = CreateOperationLevels(nodes);
        Fingerprint = CreateFingerprint(nodes, outputs);
    }

    /// <summary>Gets the fingerprint value.</summary>
    public string Fingerprint { get; }
    /// <summary>Gets the string value.</summary>
    public IReadOnlyDictionary<string, MathBlockType> Inputs => inputTypes;
    /// <summary>Gets the string value.</summary>
    public IReadOnlyDictionary<string, MathBlockType> Outputs => outputTypes;
    /// <summary>Gets the plan nodes value.</summary>
    public IReadOnlyList<MathBlockProgramNode> PlanNodes => planNodes;
    /// <summary>Gets the string value.</summary>
    public IReadOnlyDictionary<string, int> OutputNodeIndexes => outputNodeIndexes;

    /// <summary>Evaluates the typed graph with named input values.</summary>
    public IReadOnlyDictionary<string, MathBlockValue> Evaluate(
        IReadOnlyDictionary<string, MathBlockValue> inputs) =>
        MathBlocksCPUWorker.Shared.Execute(this, inputs);

    internal Node[] Nodes => nodes;
    internal IReadOnlyList<int[]> OperationLevels => operationLevels;
    internal int OutputCount => outputs.Length;

    internal string GetOutputName(int index) => outputs[index].Name;

    internal int GetOutputNodeIndex(int index) => outputs[index].NodeIndex;

    internal MathBlockValue[] CreateValueBuffer(IReadOnlyDictionary<string, MathBlockValue> inputs)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        var values = new MathBlockValue[nodes.Length];
        for (var nodeIndex = 0; nodeIndex < nodes.Length; nodeIndex++)
        {
            var node = nodes[nodeIndex];
            switch (node.Kind)
            {
                case MathBlockProgramBuilder.NodeKind.Input:
                    if (!inputs.TryGetValue(node.Name!, out var input))
                        throw new KeyNotFoundException($"Program input '{node.Name}' is missing.");
                    if (!node.Type.Accepts(input.Type))
                        throw new InvalidOperationException(
                            $"Program input '{node.Name}' requires '{node.Type}', but received '{input.Type}'.");
                    values[nodeIndex] = input;
                    break;
                case MathBlockProgramBuilder.NodeKind.Constant:
                    values[nodeIndex] = node.Value;
                    break;
                case MathBlockProgramBuilder.NodeKind.Operation:
                    break;
                default:
                    throw new InvalidOperationException("The program contains an unsupported node kind.");
            }
        }
        return values;
    }

    internal Dictionary<string, MathBlockValue> CreateOutputs(MathBlockValue[] values)
    {
        var result = new Dictionary<string, MathBlockValue>(outputs.Length, StringComparer.Ordinal);
        for (var index = 0; index < outputs.Length; index++)
        {
            var output = outputs[index];
            result.Add(output.Name, values[output.NodeIndex]);
        }
        return result;
    }

    private static int[][] CreateOperationLevels(Node[] source)
    {
        var depths = new int[source.Length];
        var levels = new List<int>?[source.Length + 1];
        var maximumDepth = 0;
        for (var nodeIndex = 0; nodeIndex < source.Length; nodeIndex++)
        {
            var node = source[nodeIndex];
            if (node.Kind != MathBlockProgramBuilder.NodeKind.Operation)
                continue;
            var depth = 1;
            for (var inputIndex = 0; inputIndex < node.Inputs.Length; inputIndex++)
            {
                var candidateDepth = depths[node.Inputs[inputIndex]] + 1;
                if (candidateDepth > depth)
                    depth = candidateDepth;
            }
            depths[nodeIndex] = depth;
            maximumDepth = Math.Max(maximumDepth, depth);
            var level = levels[depth] ??= [];
            level.Add(nodeIndex);
        }

        var result = new int[maximumDepth][];
        for (var depth = 1; depth <= maximumDepth; depth++)
            result[depth - 1] = levels[depth] is { } level
                ? MathBlockCollectionPrimitives.Copy(level)
                : [];
        return result;
    }

    private static string CreateFingerprint(Node[] nodes, IReadOnlyList<Output> outputs)
    {
        var builder = new StringBuilder();
        builder.Append("mathblock-program-v1\n");
        for (var index = 0; index < nodes.Length; index++)
        {
            var node = nodes[index];
            builder.Append(index).Append('|').Append((int)node.Kind).Append('|');
            AppendType(builder, node.Type);
            switch (node.Kind)
            {
                case MathBlockProgramBuilder.NodeKind.Input:
                    builder.Append('|').Append(node.Name);
                    break;
                case MathBlockProgramBuilder.NodeKind.Constant:
                    builder.Append('|');
                    AppendValue(builder, node.Value);
                    break;
                case MathBlockProgramBuilder.NodeKind.Operation:
                    builder.Append('|').Append(node.Operation!.Identity).Append('|');
                    foreach (var input in node.Inputs)
                        builder.Append(input).Append(',');
                    break;
            }
            builder.Append('\n');
        }
        foreach (var output in outputs)
            builder.Append("output|").Append(output.Name).Append('|').Append(output.NodeIndex).Append('\n');
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(builder.ToString()));
        var characters = new char[hash.Length * 2];
        for (var index = 0; index < hash.Length; index++)
        {
            characters[index * 2] = HexDigit(hash[index] >> 4);
            characters[index * 2 + 1] = HexDigit(hash[index] & 0x0f);
        }
        return new string(characters);
    }

    private static void AppendType(StringBuilder builder, MathBlockType type)
    {
        builder.Append((int)type.Kind).Append(':').Append(type.Rows).Append(':').Append(type.Columns).Append(':');
        AppendRational(builder, type.Unit.Dimension0);
        AppendRational(builder, type.Unit.Dimension1);
        AppendRational(builder, type.Unit.Dimension2);
        AppendRational(builder, type.Unit.Dimension3);
    }

    private static void AppendRational(StringBuilder builder, MathRational value) =>
        builder.Append(value.Numerator).Append('/').Append(value.Denominator).Append(',');

    private static void AppendValue(StringBuilder builder, MathBlockValue value)
    {
        builder.Append((int)value.Type.Kind).Append(':');
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                AppendDouble(builder, value.AsScalar());
                break;
            case MathBlockValueKind.Boolean:
                builder.Append(value.AsBoolean() ? '1' : '0');
                break;
            case MathBlockValueKind.Complex:
                AppendDouble(builder, value.AsComplex().Real);
                AppendDouble(builder, value.AsComplex().Imaginary);
                break;
            case MathBlockValueKind.Vector:
                foreach (var item in value.AsVector())
                    AppendDouble(builder, item);
                break;
            case MathBlockValueKind.Matrix:
                foreach (ref readonly var item in value.AsMatrix().Span)
                    AppendDouble(builder, item);
                break;
            case MathBlockValueKind.ComplexVector:
                foreach (var item in value.AsComplexVector())
                {
                    AppendDouble(builder, item.Real);
                    AppendDouble(builder, item.Imaginary);
                }
                break;
            case MathBlockValueKind.ComplexMatrix:
                foreach (ref readonly var item in value.AsComplexMatrix().Span)
                {
                    AppendDouble(builder, item.Real);
                    AppendDouble(builder, item.Imaginary);
                }
                break;
            case MathBlockValueKind.PointSet:
                foreach (var item in value.AsPointSet())
                {
                    AppendDouble(builder, item.X);
                    AppendDouble(builder, item.Y);
                }
                break;
            case MathBlockValueKind.Graph:
                builder.Append(value.AsGraph().VertexCount).Append(':');
                foreach (var edge in value.AsGraph())
                {
                    builder.Append(edge.From).Append(',').Append(edge.To).Append(',');
                    AppendDouble(builder, edge.Weight);
                }
                break;
            case MathBlockValueKind.RunSet:
                foreach (var run in value.AsRunSet())
                {
                    builder.Append(run.Start).Append(',').Append(run.Length).Append(',');
                    AppendDouble(builder, run.Value);
                }
                break;
            case MathBlockValueKind.BooleanVector:
                foreach (var item in value.AsBooleanVector())
                    builder.Append(item ? '1' : '0');
                break;
        }
    }

    private static void AppendDouble(StringBuilder builder, double value)
    {
        var bits = Math.ToBits(value);
        for (var shift = 60; shift >= 0; shift -= 4)
            builder.Append(HexDigit((int)((bits >> shift) & 0x0ful)));
        builder.Append(',');
    }

    private static char HexDigit(int value) =>
        value < 10 ? (char)('0' + value) : (char)('a' + value - 10);

    internal sealed class Node
    {
        public Node(MathBlockProgramBuilder.NodeDefinition definition)
        {
            Kind = definition.Kind;
            Type = definition.Type;
            Name = definition.Name;
            Value = definition.Value;
            Operation = definition.Operation;
            Inputs = MathBlockCollectionPrimitives.Copy(definition.Inputs);
        }

        public MathBlockProgramBuilder.NodeKind Kind { get; }
        public MathBlockType Type { get; }
        public string? Name { get; }
        public MathBlockValue Value { get; }
        public MathBlockOperation? Operation { get; }
        public int[] Inputs { get; }
    }

    private sealed record Output(string Name, int NodeIndex);
}
