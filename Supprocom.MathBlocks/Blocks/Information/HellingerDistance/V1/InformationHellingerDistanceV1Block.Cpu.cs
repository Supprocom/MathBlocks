namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.hellinger-distance@1</c> mathematical operation.</summary>
    public static double HellingerDistance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var sum = 0d;
        for (var index = 0; index < left.Count; index++)
        {
            var difference = Math.Sqrt(left[index]) - Math.Sqrt(right[index]);
            sum += difference * difference;
        }

        return Math.Sqrt(sum / 2d);
    }
}
