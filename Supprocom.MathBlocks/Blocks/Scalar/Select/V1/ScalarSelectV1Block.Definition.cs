namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarSelectV1Block
    {
        internal const string Identity = "scalar.select@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => ScalarSelectV1BlockCpu.Create();
    }
}
