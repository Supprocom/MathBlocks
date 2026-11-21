namespace Supprocom.MathBlocks;

internal static partial class ProbabilityMathBlocks
{
    internal static class ProbabilityNormalizeV1Block
    {
        internal const string Identity = "probability.normalize@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateVectorUnary("probability.normalize", MathBlockProbability.Normalize, MathBlockValue.Vector([1f, 3f]), [0.25f, 0.75f], requireDistribution: false);
    }
}
