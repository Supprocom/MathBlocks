namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double PopulationCovariance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var leftMean = MathBlockVectorMath.Mean(left);
        var rightMean = MathBlockVectorMath.Mean(right);
        var sum = 0d;
        for (var index = 0; index < left.Count; index++)
            sum += (left[index] - leftMean) * (right[index] - rightMean);
        return sum / left.Count;
    }
}
