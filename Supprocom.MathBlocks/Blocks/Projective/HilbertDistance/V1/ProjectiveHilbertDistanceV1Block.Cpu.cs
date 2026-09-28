
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>projective.hilbert-distance@1</c> mathematical operation.</summary>
    public static double HilbertProjectiveDistance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
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
