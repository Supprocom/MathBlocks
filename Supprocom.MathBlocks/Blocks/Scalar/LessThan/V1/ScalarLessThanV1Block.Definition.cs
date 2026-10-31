namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarLessThanV1Block
    {
        internal const string Identity = "scalar.less-than@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => ScalarLessThanV1BlockCpu.Create();
    }
}
