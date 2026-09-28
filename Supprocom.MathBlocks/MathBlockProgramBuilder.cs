namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Program Builder contract.</summary>
public sealed class MathBlockProgramBuilder
{
    private readonly MathBlockRegistry registry;
    private readonly List<NodeDefinition> nodes = [];
    private readonly List<(string Name, int Node)> outputs = [];
    private readonly HashSet<string> inputNames = new(StringComparer.Ordinal);
    private readonly HashSet<string> outputNames = new(StringComparer.Ordinal);

    /// <summary>Creates a typed program builder using the supplied operation registry.</summary>
    public MathBlockProgramBuilder(MathBlockRegistry registry) =>
        this.registry = registry ?? throw new ArgumentNullException(nameof(registry));

    /// <summary>Adds a named input node and returns its node index.</summary>
    public int Input(string name, MathBlockType type)
    {
        name = RequireName(name, nameof(name));
        if (!inputNames.Add(name))
            throw new ArgumentException($"Input '{name}' already exists.", nameof(name));
        nodes.Add(NodeDefinition.Input(name, type));
        return nodes.Count - 1;
    }

    /// <summary>Adds a constant value and returns its node index.</summary>
    public int Constant(MathBlockValue value)
    {
        if (!value.IsValid)
            throw new ArgumentException("A program constant must be valid.", nameof(value));
        nodes.Add(NodeDefinition.Constant(value));
        return nodes.Count - 1;
    }

    /// <summary>Adds an operation node over earlier node indices.</summary>
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

    /// <summary>Names a node as a program output.</summary>
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

    /// <summary>Validates and freezes the constructed program.</summary>
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
