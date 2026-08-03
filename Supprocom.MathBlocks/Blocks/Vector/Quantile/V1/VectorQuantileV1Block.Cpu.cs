namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double Quantile(IReadOnlyList<double> values, double probability)
    {
        var sorted = MathBlockCollectionPrimitives.SortedCopy(
            values,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        if (sorted.Length == 1)
            return sorted[0];
        var position = probability * (sorted.Length - 1);
        var lower = (int)Math.Floor(position);
        var upper = (int)Math.Ceiling(position);
        var weight = position - lower;
        return sorted[lower] * (1d - weight) + sorted[upper] * weight;
    }
}
