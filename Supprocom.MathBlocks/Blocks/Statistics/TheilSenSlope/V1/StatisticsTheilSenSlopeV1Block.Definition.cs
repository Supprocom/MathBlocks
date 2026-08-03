namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsTheilSenSlopeV1Block
    {
        internal const string Identity = "statistics.theil-sen-slope@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.theil-sen-slope", MathBlockStatistics.TheilSenSlope, 2d, SlopeType);
    }
}
