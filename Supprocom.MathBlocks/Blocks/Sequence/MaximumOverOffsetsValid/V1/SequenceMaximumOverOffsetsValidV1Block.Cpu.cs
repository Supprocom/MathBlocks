namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity of sequence.maximum-over-offsets@1, row by row, from the same row function as its values.
    internal static void MaximumOverOffsetsValidity(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        Span<bool> rowValid)
    {
        for (var row = 0; row < rowValid.Length; row++)
            rowValid[row] = MaximumOverOffsetsRow(x, xValid, counts, row, start, end, out _);
    }
}
