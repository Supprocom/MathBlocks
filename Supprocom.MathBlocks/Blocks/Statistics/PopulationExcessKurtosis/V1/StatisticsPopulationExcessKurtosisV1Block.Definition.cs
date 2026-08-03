namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsPopulationExcessKurtosisV1Block
    {
        internal const string Identity = "statistics.population-excess-kurtosis@1";
        internal static MathBlockOperation Create() => CreateUnaryWithSample("statistics.population-excess-kurtosis", MathBlockStatistics.PopulationExcessKurtosis, MathBlockValue.Vector([-1d, 1d]), -2d, DimensionlessStatisticType);
    }
}
