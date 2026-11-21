namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    // Row t of the lead is x[t + distance] when t + distance is inside the series, rows t through t + distance are chained
    // (counts[t + distance] >= distance) and x[t + distance] is available. Any other row holds the fill and is unavailable.
    // A distance equal to the series length leaves every row unavailable. An empty values span skips the values.
    internal static void SequenceLead(
        ReadOnlySpan<float> x,
        ReadOnlySpan<bool> available,
        ReadOnlySpan<float> counts,
        int distance,
        float fill,
        Span<float> values,
        Span<bool> valid)
    {
        for (var row = 0; row < x.Length; row++)
        {
            var found = row < x.Length - distance && counts[row + distance] >= distance && available[row + distance];
            if (!values.IsEmpty)
                values[row] = found ? x[row + distance] : fill;
            valid[row] = found;
        }
    }
}
