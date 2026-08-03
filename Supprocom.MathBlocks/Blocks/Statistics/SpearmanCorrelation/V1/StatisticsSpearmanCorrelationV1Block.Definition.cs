namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsSpearmanCorrelationV1Block
    {
        internal const string Identity = "statistics.spearman-correlation@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.spearman-correlation", MathBlockStatistics.SpearmanCorrelation, 1d, CorrelationType);
    }
}
