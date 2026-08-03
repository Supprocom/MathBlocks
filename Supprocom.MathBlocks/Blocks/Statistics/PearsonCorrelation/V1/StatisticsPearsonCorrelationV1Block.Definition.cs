namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsPearsonCorrelationV1Block
    {
        internal const string Identity = "statistics.pearson-correlation@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.pearson-correlation", MathBlockStatistics.PearsonCorrelation, 1d, CorrelationType);
    }
}
