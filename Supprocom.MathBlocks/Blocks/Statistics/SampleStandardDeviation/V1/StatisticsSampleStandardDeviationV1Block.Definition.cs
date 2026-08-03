namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsSampleStandardDeviationV1Block
    {
        internal const string Identity = "statistics.sample-standard-deviation@1";
        internal static MathBlockOperation Create() => CreateUnary("statistics.sample-standard-deviation", MathBlockStatistics.SampleStandardDeviation, Math.Sqrt(5d / 3d), StandardDeviationType);
    }
}
