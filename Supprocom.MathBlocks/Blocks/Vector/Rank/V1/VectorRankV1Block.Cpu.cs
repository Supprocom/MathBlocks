namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.rank@1</c> mathematical operation.</summary>
    public static float[] Rank(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var indexed = MathBlockCollectionPrimitives.SortedIndices(
            values,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var result = new float[values.Count];
        var start = 0;
        while (start < indexed.Length)
        {
            var end = start + 1;
            while (end < indexed.Length && values[indexed[end]] == values[indexed[start]])
                end++;
            var averageRank = (start + 1f + end) / 2f;
            for (var index = start; index < end; index++)
                result[indexed[index]] = averageRank;
            start = end;
        }

        return result;
    }
}
