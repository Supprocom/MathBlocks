namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.sort@1</c> mathematical operation.</summary>
    public static double[] Sort(IReadOnlyList<double> values) =>
        MathBlockCollectionPrimitives.SortedCopy(
            values,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
}
