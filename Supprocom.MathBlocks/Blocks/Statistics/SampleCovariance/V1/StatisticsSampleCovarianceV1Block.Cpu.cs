namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.sample-covariance@1</c> mathematical operation.</summary>
    public static double SampleCovariance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        return PopulationCovariance(left, right) * left.Count / (left.Count - 1d);
    }
}
