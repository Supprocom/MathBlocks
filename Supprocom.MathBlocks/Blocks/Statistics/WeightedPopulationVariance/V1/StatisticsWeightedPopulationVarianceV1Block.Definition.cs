namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsWeightedPopulationVarianceV1Block
    {
        internal const string Identity = "statistics.weighted-population-variance@1";
        internal static MathBlockOperation Create() => CreateWeighted("statistics.weighted-population-variance", MathBlockStatistics.WeightedPopulationVariance, 1d, VarianceType);
    }
}
