namespace Supprocom.MathBlocks;

public sealed class MathBlockFormulaBuilder
{
    private readonly MathBlockRegistry registry;
    private readonly Dictionary<string, FormulaNode> nodes = new(StringComparer.Ordinal);
    private readonly Dictionary<string, string> outputs = new(StringComparer.Ordinal);

    public MathBlockFormulaBuilder(MathBlockRegistry registry) =>
        this.registry = registry ?? throw new ArgumentNullException(nameof(registry));

    public MathBlockFormulaBuilder Input(string nodeName, MathBlockType type)
    {
        AddNode(FormulaNode.Input(RequireName(nodeName, nameof(nodeName)), type));
        return this;
    }

    public MathBlockFormulaBuilder Constant(string nodeName, MathBlockValue value)
    {
        if (!value.IsValid)
            throw new ArgumentException("A formula constant must be valid.", nameof(value));
        AddNode(FormulaNode.Constant(RequireName(nodeName, nameof(nodeName)), value));
        return this;
    }

    public MathBlockFormulaBuilder Block(
        string nodeName,
        string identifier,
        int version = 1,
        params string[] inputs)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        AddNode(FormulaNode.CreateOperation(
            RequireName(nodeName, nameof(nodeName)),
            registry.Get(identifier, version),
            MathBlockCollectionPrimitives.Map(inputs, input => RequireName(input, nameof(inputs)))));
        return this;
    }

    public MathBlockFormulaBuilder Output(string outputName, string nodeName)
    {
        outputName = RequireName(outputName, nameof(outputName));
        nodeName = RequireName(nodeName, nameof(nodeName));
        if (!outputs.TryAdd(outputName, nodeName))
            throw new ArgumentException($"Output '{outputName}' already exists.", nameof(outputName));
        return this;
    }

    public MathBlockProgram Build()
    {
        if (outputs.Count == 0)
            throw new InvalidOperationException("A formula requires an output.");

        var builder = new MathBlockProgramBuilder(registry);
        var indexes = new Dictionary<string, int>(StringComparer.Ordinal);
        var active = new HashSet<string>(StringComparer.Ordinal);

        int Resolve(string name)
        {
            if (indexes.TryGetValue(name, out var existing))
                return existing;
            if (!nodes.TryGetValue(name, out var node))
                throw new KeyNotFoundException($"Formula node '{name}' is missing.");
            if (!active.Add(name))
                throw new InvalidOperationException($"Formula node '{name}' is part of a cycle.");

            int result;
            switch (node.Kind)
            {
                case FormulaNodeKind.Input:
                    result = builder.Input(node.Name, node.Type);
                    break;
                case FormulaNodeKind.Constant:
                    result = builder.Constant(node.Value);
                    break;
                case FormulaNodeKind.Operation:
                    var inputIndexes = MathBlockCollectionPrimitives.Map(node.Inputs, Resolve);
                    result = builder.Apply(node.Operation!.Identifier, node.Operation.Version, inputIndexes);
                    break;
                default:
                    throw new InvalidOperationException("The formula contains an unsupported node kind.");
            }

            active.Remove(name);
            indexes.Add(name, result);
            return result;
        }

        foreach (var output in outputs)
            builder.Output(output.Key, Resolve(output.Value));
        return builder.Build();
    }

    private void AddNode(FormulaNode node)
    {
        if (!nodes.TryAdd(node.Name, node))
            throw new ArgumentException($"Formula node '{node.Name}' already exists.", nameof(node));
    }

    private static string RequireName(string value, string parameterName) =>
        string.IsNullOrWhiteSpace(value)
            ? throw new ArgumentException("A nonempty name is required.", parameterName)
            : value.Trim();

    private enum FormulaNodeKind
    {
        Input,
        Constant,
        Operation
    }

    private sealed class FormulaNode
    {
        private FormulaNode(
            string name,
            FormulaNodeKind kind,
            MathBlockType type = default,
            MathBlockValue value = default,
            MathBlockOperation? operation = null,
            string[]? inputs = null)
        {
            Name = name;
            Kind = kind;
            Type = type;
            Value = value;
            Operation = operation;
            Inputs = inputs ?? [];
        }

        public string Name { get; }
        public FormulaNodeKind Kind { get; }
        public MathBlockType Type { get; }
        public MathBlockValue Value { get; }
        public MathBlockOperation? Operation { get; }
        public string[] Inputs { get; }

        public static FormulaNode Input(string name, MathBlockType type) =>
            new(name, FormulaNodeKind.Input, type);

        public static FormulaNode Constant(string name, MathBlockValue value) =>
            new(name, FormulaNodeKind.Constant, value: value);

        public static FormulaNode CreateOperation(string name, MathBlockOperation operation, string[] inputs) =>
            new(name, FormulaNodeKind.Operation, operation: operation, inputs: inputs);
    }
}
