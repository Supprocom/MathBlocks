namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Rank(IReadOnlyList<double> values)
    {
        var indexed = MathBlockCollectionPrimitives.SortedIndices(
            values,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var result = new double[values.Count];
        var start = 0;
        while (start < indexed.Length)
        {
            var end = start + 1;
            while (end < indexed.Length && values[indexed[end]] == values[indexed[start]])
                end++;
            var averageRank = (start + 1d + end) / 2d;
            for (var index = start; index < end; index++)
                result[indexed[index]] = averageRank;
            start = end;
        }

        return result;
    }
}
