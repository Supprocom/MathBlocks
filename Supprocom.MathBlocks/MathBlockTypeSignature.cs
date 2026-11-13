namespace Supprocom.MathBlocks;

/// <summary>Describes an operation's output-type rule as data, so the host and the CUDA type-rule module run one resolver.</summary>
/// <remarks>
/// The rule kind and parameters define the output kind, shape and unit; the operands define the accepted kinds and the
/// unit constraints that the inputs must satisfy. <see cref="MathBlockTypeSignatures.Resolve"/> and the CUDA function
/// <c>mathblocks_type_resolve</c> read the same <see cref="ToRow"/> ints.
/// </remarks>
public sealed record MathBlockTypeSignature
{
    private readonly int[] row;

    /// <summary>Creates a signature.</summary>
    public MathBlockTypeSignature(
        string identity,
        MathBlockTypeRuleKind ruleKind,
        IReadOnlyList<int> parameters,
        IReadOnlyList<MathBlockTypeOperand> operands)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(identity);
        ArgumentNullException.ThrowIfNull(parameters);
        ArgumentNullException.ThrowIfNull(operands);
        Identity = identity;
        RuleKind = ruleKind;
        Parameters = Array.AsReadOnly(Copy(parameters));
        Operands = Array.AsReadOnly(Copy(operands));
        row = BuildRow(ruleKind, Parameters, Operands);
    }

    /// <summary>Gets the identity of the operation.</summary>
    public string Identity { get; }
    /// <summary>Gets how the output type is computed.</summary>
    public MathBlockTypeRuleKind RuleKind { get; }
    /// <summary>Gets the rule parameters, which the rule kind documents.</summary>
    public IReadOnlyList<int> Parameters { get; }
    /// <summary>Gets what each operand accepts.</summary>
    public IReadOnlyList<MathBlockTypeOperand> Operands { get; }

    /// <summary>Gets the signature row: the rule, the parameter count, the parameters, the operand count, then the accepted kind mask, unit constraint and constant flag of each operand.</summary>
    public IReadOnlyList<int> ToRow() => Array.AsReadOnly(row);

    internal ReadOnlySpan<int> RowSpan => row;

    /// <summary>Tests whether another signature has the same identity and the same row.</summary>
    public bool Equals(MathBlockTypeSignature? other) =>
        other is not null &&
        string.Equals(Identity, other.Identity, StringComparison.Ordinal) &&
        row.AsSpan().SequenceEqual(other.row);

    /// <summary>Gets a hash code of the identity and the row.</summary>
    public override int GetHashCode()
    {
        var hash = new HashCode();
        hash.Add(Identity, StringComparer.Ordinal);
        foreach (var value in row)
            hash.Add(value);
        return hash.ToHashCode();
    }

    private static T[] Copy<T>(IReadOnlyList<T> source)
    {
        var copy = new T[source.Count];
        for (var index = 0; index < copy.Length; index++)
            copy[index] = source[index];
        return copy;
    }

    private static int[] BuildRow(
        MathBlockTypeRuleKind ruleKind,
        IReadOnlyList<int> parameters,
        IReadOnlyList<MathBlockTypeOperand> operands)
    {
        var values = new List<int>(3 + parameters.Count + operands.Count * 3) { (int)ruleKind, parameters.Count };
        values.AddRange(parameters);
        values.Add(operands.Count);
        foreach (var operand in operands)
        {
            values.Add(operand.AcceptedKindMask);
            values.Add(operand.UnitConstraint);
            values.Add(operand.IsConstant ? 1 : 0);
        }
        return [.. values];
    }
}
