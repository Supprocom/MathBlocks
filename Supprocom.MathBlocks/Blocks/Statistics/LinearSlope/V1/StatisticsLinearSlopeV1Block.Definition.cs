namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsLinearSlopeV1Block
    {
        internal const string Identity = "statistics.linear-slope@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.linear-slope", MathBlockStatistics.LinearSlope, 2d, SlopeType);
    }
}
