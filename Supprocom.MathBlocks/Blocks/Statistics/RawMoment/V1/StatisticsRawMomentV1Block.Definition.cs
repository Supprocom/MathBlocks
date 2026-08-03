namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class StatisticsRawMomentV1Block
    {
        internal const string Identity = "statistics.raw-moment@1";
        internal static MathBlockOperation Create() => CreateMoment("statistics.raw-moment", MathBlockAdvanced.RawMoment, 14d / 3d);
    }
}
