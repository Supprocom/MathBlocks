namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // Row row of sequence.first-true-offset@1: the first offset in start..end whose predicate row is nonzero (a negative zero is
    // false), or noMatch when none is. An unreachable row or an unavailable predicate row met before a match makes the row
    // invalid; the rows after the first match are never read.
    internal static bool FirstTrueOffsetRow(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int row,
        int start,
        int end,
        double noMatch,
        out double value)
    {
        value = 0d;
        for (long offset = start; offset <= end; offset++)
        {
            if (!OffsetIsReachable(counts, row, offset))
                return false;
            var target = (int)(row + offset);
            if (!predicateValid[target])
                return false;
            if (predicate[target] != 0d)
            {
                value = offset;
                return true;
            }
        }
        value = noMatch;
        return true;
    }

    // The values of sequence.first-true-offset@1: each invalid row holds fill.
    internal static void FirstTrueOffsetValues(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        double noMatch,
        double fill,
        Span<double> values,
        Span<bool> rowValid)
    {
        for (var row = 0; row < values.Length; row++)
        {
            rowValid[row] = FirstTrueOffsetRow(predicate, predicateValid, counts, row, start, end, noMatch, out var value);
            values[row] = rowValid[row] ? value : fill;
        }
    }
}
