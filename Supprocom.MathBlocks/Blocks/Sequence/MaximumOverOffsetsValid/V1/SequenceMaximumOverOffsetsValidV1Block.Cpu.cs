namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity of sequence.maximum-over-offsets@1, row by row, from the same reach and availability rules as its values.
    internal static void MaximumOverOffsetsValidity(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> xValid,
        ReadOnlySpan<float> counts,
        int start,
        int end,
        Span<bool> rowValid)
    {
        OffsetValidityRows(x, xValid, counts, start, end, false, rowValid);
    }
}
