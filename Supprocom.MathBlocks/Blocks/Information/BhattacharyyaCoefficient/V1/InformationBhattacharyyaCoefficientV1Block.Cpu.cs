namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.bhattacharyya-coefficient@1</c> mathematical operation.</summary>
    public static double BhattacharyyaCoefficient(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var sum = 0d;
        for (var index = 0; index < left.Count; index++)
            sum += Math.Sqrt(left[index] * right[index]);
        return sum;
    }
}
