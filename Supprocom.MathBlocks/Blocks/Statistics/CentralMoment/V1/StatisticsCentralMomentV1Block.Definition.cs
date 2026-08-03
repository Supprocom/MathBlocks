namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class StatisticsCentralMomentV1Block
    {
        internal const string Identity = "statistics.central-moment@1";
        internal static MathBlockOperation Create() => CreateMoment("statistics.central-moment", MathBlockAdvanced.CentralMoment, 2d / 3d);
    }
}
