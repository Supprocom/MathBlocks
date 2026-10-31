namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarGreaterThanV1Block
    {
        internal const string Identity = "scalar.greater-than@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => ScalarGreaterThanV1BlockCpu.Create();
    }
}
