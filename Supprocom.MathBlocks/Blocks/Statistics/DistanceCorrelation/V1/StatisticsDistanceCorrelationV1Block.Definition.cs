namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsDistanceCorrelationV1Block
    {
        internal const string Identity = "statistics.distance-correlation@1";
        internal static MathBlockOperation Create() => CreateBinaryWithSamples("statistics.distance-correlation", MathBlockStatistics.DistanceCorrelation, MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Vector([3d, 5d, 7d]), 1d, CorrelationType);
    }
}
