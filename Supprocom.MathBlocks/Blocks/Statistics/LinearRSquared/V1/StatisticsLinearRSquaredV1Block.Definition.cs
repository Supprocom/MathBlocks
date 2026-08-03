namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsLinearRSquaredV1Block
    {
        internal const string Identity = "statistics.linear-r-squared@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.linear-r-squared", MathBlockStatistics.LinearRSquared, 1d, CorrelationType);
    }
}
