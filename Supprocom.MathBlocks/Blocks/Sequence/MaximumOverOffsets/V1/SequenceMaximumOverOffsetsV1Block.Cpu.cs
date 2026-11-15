namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // Row row of sequence.maximum-over-offsets@1: the maximum of x[row + start] .. x[row + end] from a start of negative infinity,
    // by scalar.maximum's rule (Math.Max), so the maximum of -0.0 and 0.0 is 0.0. The row is invalid when a row of the span is
    // unreachable or unavailable.
    internal static bool MaximumOverOffsetsRow(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<double> counts,
        int row,
        int start,
        int end,
        out double value)
    {
        value = 0d;
        if (!OffsetSpanIsReachable(counts, row, start, end))
            return false;
        var maximum = double.NegativeInfinity;
        for (long index = row + (long)start; index <= row + (long)end; index++)
        {
            if (!xValid[(int)index])
                return false;
            maximum = Math.Max(maximum, x[(int)index]);
        }
        value = maximum;
        return true;
    }

    // The values of sequence.maximum-over-offsets@1: each invalid row holds fill.
    internal static void MaximumOverOffsetsValues(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        double fill,
        Span<double> values,
        Span<bool> rowValid)
    {
        for (var row = 0; row < values.Length; row++)
        {
            rowValid[row] = MaximumOverOffsetsRow(x, xValid, counts, row, start, end, out var value);
            values[row] = rowValid[row] ? value : fill;
        }
    }
}
