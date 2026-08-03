namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double BhattacharyyaCoefficient(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var sum = 0d;
        for (var index = 0; index < left.Count; index++)
            sum += Math.Sqrt(left[index] * right[index]);
        return sum;
    }
}
