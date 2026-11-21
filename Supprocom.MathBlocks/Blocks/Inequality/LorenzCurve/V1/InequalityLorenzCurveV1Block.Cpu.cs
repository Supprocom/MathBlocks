
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>inequality.lorenz-curve@1</c> mathematical operation.</summary>
    public static float[] LorenzCurve(IReadOnlyList<float> values)
    {
        var sorted = MathBlockCollectionPrimitives.SortedCopy(
            values,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var total = MathBlockVectorMath.Sum(sorted);
        var result = new float[sorted.Length + 1];
        for (var index = 0; index < sorted.Length; index++)
            result[index + 1] = result[index] + sorted[index] / total;
        return result;
    }
}
