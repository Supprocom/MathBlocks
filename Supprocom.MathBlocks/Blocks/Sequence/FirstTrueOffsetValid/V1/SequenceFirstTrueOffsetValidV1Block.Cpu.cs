namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // The validity of sequence.first-true-offset@1, row by row, from the same pass as its values.
    internal static void FirstTrueOffsetValidity(
        ReadOnlySpan<double> predicate,
        ReadOnlySpan<bool> predicateValid,
        ReadOnlySpan<double> counts,
        int start,
        int end,
        Span<bool> rowValid)
    {
        FirstTrueOffsetRows(predicate, predicateValid, counts, start, end, 0d, 0d, [], rowValid, false);
    }
}
