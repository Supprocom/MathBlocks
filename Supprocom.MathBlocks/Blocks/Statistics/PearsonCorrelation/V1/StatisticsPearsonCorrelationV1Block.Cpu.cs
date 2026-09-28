namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.pearson-correlation@1</c> mathematical operation.</summary>
    public static double PearsonCorrelation(IReadOnlyList<double> left, IReadOnlyList<double> right) => PopulationCovariance(left, right) / (PopulationStandardDeviation(left) * PopulationStandardDeviation(right));
}
