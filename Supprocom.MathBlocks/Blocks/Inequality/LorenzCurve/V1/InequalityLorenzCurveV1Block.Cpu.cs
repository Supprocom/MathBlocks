
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] LorenzCurve(IReadOnlyList<double> values)
    {
        var sorted = MathBlockCollectionPrimitives.SortedCopy(
            values,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var total = MathBlockVectorMath.Sum(sorted);
        var result = new double[sorted.Length + 1];
        for (var index = 0; index < sorted.Length; index++)
            result[index + 1] = result[index] + sorted[index] / total;
        return result;
    }
}
