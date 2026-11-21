namespace Supprocom.MathBlocks;

internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsDistanceCorrelationV1Block
    {
        internal const string Identity = "statistics.distance-correlation@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateBinaryWithSamples("statistics.distance-correlation", MathBlockStatistics.DistanceCorrelation, MathBlockValue.Vector([1f, 2f, 3f]), MathBlockValue.Vector([3f, 5f, 7f]), 1f, CorrelationType);
    }
}
