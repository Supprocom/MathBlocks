namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsMedianAbsoluteDeviationV1Block
    {
        internal const string Identity = "statistics.median-absolute-deviation@1";
        internal static MathBlockOperation Create() => CreateUnary("statistics.median-absolute-deviation", MathBlockStatistics.MedianAbsoluteDeviation, 1d, StandardDeviationType);
    }
}
