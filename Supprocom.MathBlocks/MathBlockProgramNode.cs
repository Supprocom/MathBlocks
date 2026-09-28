namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Program Node contract.</summary>
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

    /// <summary>Gets the index value.</summary>
    public int Index { get; }
    /// <summary>Gets the kind value.</summary>
    public MathBlockProgramNodeKind Kind { get; }
    /// <summary>Gets the type value.</summary>
    public MathBlockType Type { get; }
    /// <summary>Gets the name value.</summary>
    public string? Name { get; }
    /// <summary>Gets the value value.</summary>
    public MathBlockValue Value { get; }
    /// <summary>Gets the operation identity value.</summary>
    public string? OperationIdentity { get; }
    /// <summary>Gets the inputs value.</summary>
    public IReadOnlyList<int> Inputs { get; }
}
