namespace Supprocom.MathBlocks;

internal static partial class ProbabilityMathBlocks
{
    internal static class SpecialBetaV1Block
    {
        internal const string Identity = "special.beta@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("special.beta", MathBlockProbability.Beta, 2f, 3f, 1f / 12f, MathBlockTypeRules.DimensionlessBinaryScalar, 3e-5f);
    }
}
