namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double LinearSlope(IReadOnlyList<double> x, IReadOnlyList<double> y) => PopulationCovariance(x, y) / PopulationVariance(x);
}
