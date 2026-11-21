namespace Supprocom.MathBlocks;

internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsPopulationSkewnessV1Block
    {
        internal const string Identity = "statistics.population-skewness@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateUnaryWithSample("statistics.population-skewness", MathBlockStatistics.PopulationSkewness, MathBlockValue.Vector([-1f, 0f, 1f]), 0f, DimensionlessStatisticType);
    }
}
