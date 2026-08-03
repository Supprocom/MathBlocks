namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsPopulationVarianceV1Block
    {
        internal const string Identity = "statistics.population-variance@1";
        internal static MathBlockOperation Create() => CreateUnary("statistics.population-variance", MathBlockStatistics.PopulationVariance, 1.25d, VarianceType);
    }
}
