namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.population-covariance@1</c> mathematical operation.</summary>
    public static double PopulationCovariance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var leftMean = MathBlockVectorMath.Mean(left);
        var rightMean = MathBlockVectorMath.Mean(right);
        var sum = 0d;
        for (var index = 0; index < left.Count; index++)
            sum += (left[index] - leftMean) * (right[index] - rightMean);
        return sum / left.Count;
    }
}
