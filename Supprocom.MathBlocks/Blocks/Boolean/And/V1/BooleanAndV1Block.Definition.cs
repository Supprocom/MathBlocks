namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class BooleanAndV1Block
    {
        internal const string Identity = "boolean.and@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => BooleanAndV1BlockCpu.Create();
    }
}
