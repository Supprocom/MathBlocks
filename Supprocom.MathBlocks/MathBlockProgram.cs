using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks;

public sealed class MathBlockProgramBuilder
{
    private readonly MathBlockRegistry registry;
    private readonly List<NodeDefinition> nodes = [];
    private readonly List<(string Name, int Node)> outputs = [];
    private readonly HashSet<string> inputNames = new(StringComparer.Ordinal);
    private readonly HashSet<string> outputNames = new(StringComparer.Ordinal);

    public MathBlockProgramBuilder(MathBlockRegistry registry) =>
        this.registry = registry ?? throw new ArgumentNullException(nameof(registry));

    public int Input(string name, MathBlockType type)
    {
        name = RequireName(name, nameof(name));
        if (!inputNames.Add(name))
            throw new ArgumentException($"Input '{name}' already exists.", nameof(name));
        nodes.Add(NodeDefinition.Input(name, type));
        return nodes.Count - 1;
    }

    public int Constant(MathBlockValue value)
    {
        if (!value.IsValid)
            throw new ArgumentException("A program constant must be valid.", nameof(value));
        nodes.Add(NodeDefinition.Constant(value));
        return nodes.Count - 1;
    }

    public int Apply(string identifier, int version = 1, params int[] inputs)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        var operation = registry.Get(identifier, version);
        for (var index = 0; index < inputs.Length; index++)
            if (inputs[index] < 0 || inputs[index] >= nodes.Count)
                throw new ArgumentOutOfRangeException(nameof(inputs), "An operation input must reference an earlier node.");
        var inputTypes = MathBlockCollectionPrimitives.Map(inputs, index => nodes[index].Type);
        var outputType = operation.ResolveOutputType(inputTypes);
        nodes.Add(NodeDefinition.CreateOperation(operation, inputs, outputType));
        return nodes.Count - 1;
    }

    public MathBlockProgramBuilder Output(string name, int node)
    {
        name = RequireName(name, nameof(name));
        if ((uint)node >= (uint)nodes.Count)
            throw new ArgumentOutOfRangeException(nameof(node));
        if (!outputNames.Add(name))
            throw new ArgumentException($"Output '{name}' already exists.", nameof(name));
        outputs.Add((name, node));
        return this;
    }

    public MathBlockProgram Build()
    {
        if (outputs.Count == 0)
            throw new InvalidOperationException("A program requires an output.");
        return new MathBlockProgram(nodes, outputs);
    }

    private static string RequireName(string value, string parameterName) =>
        string.IsNullOrWhiteSpace(value)
            ? throw new ArgumentException("A nonempty name is required.", parameterName)
            : value.Trim();

    internal enum NodeKind
    {
        Input,
        Constant,
        Operation
    }

    internal sealed class NodeDefinition
    {
        private NodeDefinition(
            NodeKind kind,
            MathBlockType type,
            string? name = null,
            MathBlockValue value = default,
            MathBlockOperation? operation = null,
            int[]? inputs = null)
        {
            Kind = kind;
            Type = type;
            Name = name;
            Value = value;
            Operation = operation;
            Inputs = inputs ?? [];
        }

        public NodeKind Kind { get; }
        public MathBlockType Type { get; }
        public string? Name { get; }
        public MathBlockValue Value { get; }
        public MathBlockOperation? Operation { get; }
        public int[] Inputs { get; }

        public static NodeDefinition Input(string name, MathBlockType type) => new(NodeKind.Input, type, name);
        public static NodeDefinition Constant(MathBlockValue value) => new(NodeKind.Constant, value.Type, value: value);
        public static NodeDefinition CreateOperation(MathBlockOperation operation, int[] inputs, MathBlockType type) =>
            new(NodeKind.Operation, type, operation: operation, inputs: MathBlockCollectionPrimitives.Copy(inputs));
    }
}

public sealed class MathBlockProgram
{
    private readonly Node[] nodes;
    private readonly int[][] operationLevels;
    private readonly Output[] outputs;
    private readonly IReadOnlyList<MathBlockProgramNode> planNodes;
    private readonly IReadOnlyDictionary<string, MathBlockType> inputTypes;
    private readonly IReadOnlyDictionary<string, MathBlockType> outputTypes;
    private readonly IReadOnlyDictionary<string, int> outputNodeIndexes;

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

    public string Fingerprint { get; }
    public IReadOnlyDictionary<string, MathBlockType> Inputs => inputTypes;
    public IReadOnlyDictionary<string, MathBlockType> Outputs => outputTypes;
    public IReadOnlyList<MathBlockProgramNode> PlanNodes => planNodes;
    public IReadOnlyDictionary<string, int> OutputNodeIndexes => outputNodeIndexes;

    public IReadOnlyDictionary<string, MathBlockValue> Evaluate(
        IReadOnlyDictionary<string, MathBlockValue> inputs) =>
        MathBlocksCPUWorker.Shared.Execute(this, inputs);

    internal IReadOnlyList<Node> Nodes => nodes;
    internal IReadOnlyList<int[]> OperationLevels => operationLevels;

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

    internal IReadOnlyDictionary<string, MathBlockValue> CreateOutputs(MathBlockValue[] values)
    {
        var result = new Dictionary<string, MathBlockValue>(outputs.Length, StringComparer.Ordinal);
        for (var index = 0; index < outputs.Length; index++)
        {
            var output = outputs[index];
            result.Add(output.Name, values[output.NodeIndex]);
        }
        return result;
    }

    private static int[][] CreateOperationLevels(IReadOnlyList<Node> source)
    {
        var depths = new int[source.Count];
        var levels = new List<int>?[source.Count + 1];
        var maximumDepth = 0;
        for (var nodeIndex = 0; nodeIndex < source.Count; nodeIndex++)
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

    private static string CreateFingerprint(IReadOnlyList<Node> nodes, IReadOnlyList<Output> outputs)
    {
        var builder = new StringBuilder();
        builder.Append("mathblock-program-v1\n");
        for (var index = 0; index < nodes.Count; index++)
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
                foreach (var item in value.AsMatrix().Span)
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
                foreach (var item in value.AsComplexMatrix().Span)
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

public enum MathBlockProgramNodeKind
{
    Input,
    Constant,
    Operation
}

public sealed class MathBlockProgramNode
{
    internal MathBlockProgramNode(int index, MathBlockProgram.Node node)
    {
        Index = index;
        Kind = (MathBlockProgramNodeKind)node.Kind;
        Type = node.Type;
        Name = node.Name;
        Value = node.Value;
        OperationIdentity = node.Operation?.Identity;
        Inputs = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(node.Inputs));
    }

    public int Index { get; }
    public MathBlockProgramNodeKind Kind { get; }
    public MathBlockType Type { get; }
    public string? Name { get; }
    public MathBlockValue Value { get; }
    public string? OperationIdentity { get; }
    public IReadOnlyList<int> Inputs { get; }
}
