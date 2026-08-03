namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsInterquartileRangeV1Block
    {
        internal const string Identity = "statistics.interquartile-range@1";
        internal static MathBlockOperation Create() => CreateUnary("statistics.interquartile-range", MathBlockStatistics.InterquartileRange, 1.5d, StandardDeviationType);
    }
}
