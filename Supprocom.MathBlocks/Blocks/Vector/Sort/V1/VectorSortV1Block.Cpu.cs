namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Sort(IReadOnlyList<double> values) =>
        MathBlockCollectionPrimitives.SortedCopy(
            values,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
}
