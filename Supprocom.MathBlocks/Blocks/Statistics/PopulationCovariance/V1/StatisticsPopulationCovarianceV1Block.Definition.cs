namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsPopulationCovarianceV1Block
    {
        internal const string Identity = "statistics.population-covariance@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.population-covariance", MathBlockStatistics.PopulationCovariance, 2.5d, CovarianceType);
    }
}
