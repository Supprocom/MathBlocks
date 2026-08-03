namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsKendallTauBV1Block
    {
        internal const string Identity = "statistics.kendall-tau-b@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.kendall-tau-b", MathBlockStatistics.KendallTauB, 1d, CorrelationType);
    }
}
