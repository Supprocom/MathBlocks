namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double PearsonCorrelation(IReadOnlyList<double> left, IReadOnlyList<double> right) => PopulationCovariance(left, right) / (PopulationStandardDeviation(left) * PopulationStandardDeviation(right));
}
