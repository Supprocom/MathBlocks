
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double HilbertProjectiveDistance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var minimum = Math.PositiveInfinity;
        var maximum = Math.NegativeInfinity;
        for (var index = 0; index < left.Count; index++)
        {
            var ratio = left[index] / right[index];
            minimum = Math.Min(minimum, ratio);
            maximum = Math.Max(maximum, ratio);
        }

        return MathBlockScalar.NaturalLogarithm(maximum / minimum);
    }
}
