
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double FisherRaoDistance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var affinity = 0d;
        for (var index = 0; index < left.Count; index++)
            affinity += MathBlockScalar.SquareRoot(left[index] * right[index]);
        return 2d * MathBlockScalar.ArcCosine(MathBlockScalar.Clamp(affinity, -1d, 1d));
    }
}
