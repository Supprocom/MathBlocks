namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsSampleCovarianceV1Block
    {
        internal const string Identity = "statistics.sample-covariance@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.sample-covariance", MathBlockStatistics.SampleCovariance, 10d / 3d, CovarianceType);
    }
}
