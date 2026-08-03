namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double TotalVariationDistance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var sum = 0d;
        for (var index = 0; index < left.Count; index++)
            sum += Math.Abs(left[index] - right[index]);
        return sum / 2d;
    }
}
