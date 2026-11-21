namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class StatisticsRawMomentV1Block
    {
        internal const string Identity = "statistics.raw-moment@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateMoment("statistics.raw-moment", MathBlockAdvanced.RawMoment, 14f / 3f);
    }
}
