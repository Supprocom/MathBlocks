namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // Row row of sequence.sum-over-offsets@1: 0.0 plus x[row + start] .. x[row + end] added left to right, so 0.0 + -0.0 is 0.0.
    // The row is invalid when a row of the span is unreachable or unavailable, or when a running sum is not finite.
    internal static bool SumOverOffsetsRow(
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
        var sum = 0d;
        for (long index = row + (long)start; index <= row + (long)end; index++)
        {
            if (!xValid[(int)index])
                return false;
            sum += x[(int)index];
            if (!double.IsFinite(sum))
                return false;
        }
        value = sum;
        return true;
    }

    // The values of sequence.sum-over-offsets@1: each invalid row holds fill.
    internal static void SumOverOffsetsValues(
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
            rowValid[row] = SumOverOffsetsRow(x, xValid, counts, row, start, end, out var value);
            values[row] = rowValid[row] ? value : fill;
        }
    }
}
