namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class SpecialLogGammaV1Block
    {
        internal const string Identity = "special.log-gamma@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarUnary("special.log-gamma", MathBlockProbability.LogGamma, 5d, Math.Log(24d), MathBlockTypeRules.DimensionlessScalar, 1e-9);
    }
}
