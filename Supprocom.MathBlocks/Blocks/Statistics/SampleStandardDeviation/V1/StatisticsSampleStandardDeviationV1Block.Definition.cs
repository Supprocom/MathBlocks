namespace Supprocom.MathBlocks;

internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsSampleStandardDeviationV1Block
    {
        internal const string Identity = "statistics.sample-standard-deviation@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateUnary("statistics.sample-standard-deviation", MathBlockStatistics.SampleStandardDeviation, Math.Sqrt(5f / 3f), StandardDeviationType);
    }
}
