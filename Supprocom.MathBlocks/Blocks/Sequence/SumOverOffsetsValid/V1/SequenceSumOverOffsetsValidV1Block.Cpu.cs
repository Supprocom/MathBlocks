namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity of sequence.sum-over-offsets@1, row by row, from the same reach and availability rules as its values.
    internal static void SumOverOffsetsValidity(
        ReadOnlySpan<double> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        Span<bool> rowValid)
    {
        OffsetValidityRows(x, xValid, counts, start, end, true, rowValid);
    }
}
