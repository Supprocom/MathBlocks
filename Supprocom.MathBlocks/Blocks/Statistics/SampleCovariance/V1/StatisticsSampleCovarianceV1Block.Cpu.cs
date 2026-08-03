namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double SampleCovariance(IReadOnlyList<double> left, IReadOnlyList<double> right) => PopulationCovariance(left, right) * left.Count / (left.Count - 1d);
}
