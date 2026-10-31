namespace Supprocom.MathBlocks;

internal static partial class ScalarMathBlocks
{
    internal static class ScalarRoundV1Block
    {
        internal const string Identity = "scalar.round@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("scalar.round", MathBlockScalar.Round, 2.5d, 2d);
    }
}
