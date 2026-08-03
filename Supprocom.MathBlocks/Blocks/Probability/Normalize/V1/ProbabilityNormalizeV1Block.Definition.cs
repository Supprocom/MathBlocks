namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class ProbabilityNormalizeV1Block
    {
        internal const string Identity = "probability.normalize@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("probability.normalize", MathBlockProbability.Normalize, MathBlockValue.Vector([1d, 3d]), [0.25d, 0.75d], requireDistribution: false);
    }
}
