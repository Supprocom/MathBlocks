namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsSampleVarianceV1Block
    {
        internal const string Identity = "statistics.sample-variance@1";
        internal static MathBlockOperation Create() => CreateUnary("statistics.sample-variance", MathBlockStatistics.SampleVariance, 5d / 3d, VarianceType);
    }
}
