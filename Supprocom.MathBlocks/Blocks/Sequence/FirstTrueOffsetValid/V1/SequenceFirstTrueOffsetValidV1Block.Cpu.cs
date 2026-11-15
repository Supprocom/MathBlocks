namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity of sequence.first-true-offset@1, row by row, from the same row function as its values.
    internal static void FirstTrueOffsetValidity(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        Span<bool> rowValid)
    {
        for (var row = 0; row < rowValid.Length; row++)
            rowValid[row] = FirstTrueOffsetRow(predicate, predicateValid, counts, row, start, end, 0d, out _);
    }
}
