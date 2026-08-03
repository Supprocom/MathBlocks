namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsPopulationStandardDeviationV1Block
    {
        internal const string Identity = "statistics.population-standard-deviation@1";
        internal static MathBlockOperation Create() => CreateUnary("statistics.population-standard-deviation", MathBlockStatistics.PopulationStandardDeviation, Math.Sqrt(1.25d), StandardDeviationType);
    }
}
