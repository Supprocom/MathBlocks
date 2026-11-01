namespace Supprocom.MathBlocks;

/// <summary>Holds the outputs of a fused expression, each output's row validity, and the invalid mask.</summary>
public sealed class MathBlockFusedResult
{
    internal MathBlockFusedResult(
        IReadOnlyDictionary<string, MathBlockValue> outputs,
        IReadOnlyDictionary<string, MathBlockValue> validity,
        ulong invalidMask)
    {
        Outputs = outputs;
        Validity = validity;
        InvalidMask = invalidMask;
    }

    /// <summary>Gets each output by name, equal to the output of the unfused program.</summary>
    public IReadOnlyDictionary<string, MathBlockValue> Outputs { get; }

    /// <summary>Gets each output's row validity by output name, as a Boolean vector.</summary>
    /// <remarks>
    /// Row t is true when row t of every contributing vector input is valid according to its validity input, and no
    /// <c>elementwise.*</c> form on the path to the output holds its fill at row t. An input without a validity input
    /// is valid in every row.
    /// </remarks>
    public IReadOnlyDictionary<string, MathBlockValue> Validity { get; }

    /// <summary>Gets the invalid mask: bit k is set when operation node k produced a nonfinite row.</summary>
    /// <remarks>Operation nodes are numbered in program node order; see <see cref="MathBlockFusedExpression.MaskNodeIndexes"/>.</remarks>
    public ulong InvalidMask { get; }
}
