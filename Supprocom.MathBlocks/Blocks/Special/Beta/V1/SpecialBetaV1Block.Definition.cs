namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class SpecialBetaV1Block
    {
        internal const string Identity = "special.beta@1";
        internal static MathBlockOperation Create() => MathBlockOperationFactory.ScalarBinary("special.beta", MathBlockProbability.Beta, 2d, 3d, 1d / 12d, MathBlockTypeRules.DimensionlessBinaryScalar, 1e-9);
    }
}
