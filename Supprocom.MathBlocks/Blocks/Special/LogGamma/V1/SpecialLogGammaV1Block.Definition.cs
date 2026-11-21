namespace Supprocom.MathBlocks;

internal static partial class ProbabilityMathBlocks
{
    internal static class SpecialLogGammaV1Block
    {
        internal const string Identity = "special.log-gamma@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("special.log-gamma", MathBlockProbability.LogGamma, 5f, Math.Log(24f), MathBlockTypeRules.DimensionlessScalar, 1e-9f);
    }
}
