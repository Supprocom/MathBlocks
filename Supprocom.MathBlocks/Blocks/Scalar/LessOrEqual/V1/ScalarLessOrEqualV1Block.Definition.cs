namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarLessOrEqualV1Block
    {
        internal const string Identity = "scalar.less-or-equal@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => ScalarLessOrEqualV1BlockCpu.Create();
    }
}
