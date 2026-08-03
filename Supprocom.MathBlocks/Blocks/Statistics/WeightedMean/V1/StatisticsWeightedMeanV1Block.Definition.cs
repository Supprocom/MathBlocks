namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsWeightedMeanV1Block
    {
        internal const string Identity = "statistics.weighted-mean@1";
        internal static MathBlockOperation Create() => CreateWeighted("statistics.weighted-mean", MathBlockStatistics.WeightedMean, 3d, StandardDeviationType);
    }
}
