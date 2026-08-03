namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class ProbabilityNormalCdfV1Block
    {
        internal const string Identity = "probability.normal-cdf@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("probability.normal-cdf", MathBlockProbability.NormalCdf, 0d, 0.5d, MathBlockTypeRules.DimensionlessScalar, 1e-12);
    }
}
