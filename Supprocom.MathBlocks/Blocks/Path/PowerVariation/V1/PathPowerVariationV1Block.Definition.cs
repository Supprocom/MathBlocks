namespace Supprocom.MathBlocks;

internal static partial class PathMathBlocks
{
    internal static class PathPowerVariationV1Block
    {
        internal const string Identity = "path.power-variation@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => PathPowerVariationV1BlockCpu.Create();
    }
}
