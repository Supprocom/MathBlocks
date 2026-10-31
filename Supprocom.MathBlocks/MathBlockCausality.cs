namespace Supprocom.MathBlocks;

/// <summary>Classifies which input rows an operation's output reads.</summary>
/// <remarks>
/// <para>
/// Rows are the positions of an operation's vector-kind inputs (<see cref="MathBlockValueKind.Vector"/>,
/// <see cref="MathBlockValueKind.BooleanVector"/> and <see cref="MathBlockValueKind.ComplexVector"/>). Every other
/// input is a parameter and stays fixed.
/// </para>
/// <para>
/// Row mapping: let n be the length of the first vector-kind input and m the length of a vector-kind output. When
/// m &lt;= n the output is aligned to the end of the input, so output row j is input row j + n - m; an output that is
/// shorter than its input omits leading rows. When m &gt; n, output row j is input row j, and output rows from n on
/// follow the last input row.
/// </para>
/// <para>
/// For <see cref="Pointwise"/>, <see cref="Trailing"/> and <see cref="Expanding"/>, output row t does not depend on
/// the values of input rows after t, nor on how many rows follow t.
/// </para>
/// </remarks>
public enum MathBlockCausality
{
    /// <summary>Output row t reads input row t only.</summary>
    Pointwise,
    /// <summary>
    /// Output row t reads input rows t - w + 1 through t, where w is the input that
    /// <see cref="MathBlockCausalityInfo.WidthInputIndex"/> names.
    /// </summary>
    Trailing,
    /// <summary>Output row t reads input rows 0 through t.</summary>
    Expanding,
    /// <summary>
    /// An output row, or an output that is not a vector kind, can read every input row, including rows after it, or
    /// depends on the number of rows.
    /// </summary>
    WholeSeries,
    /// <summary>Output row t reads input rows after t.</summary>
    Forward,
    /// <summary>The operation has no vector-kind input, so it has no row semantics.</summary>
    NotSeries
}
