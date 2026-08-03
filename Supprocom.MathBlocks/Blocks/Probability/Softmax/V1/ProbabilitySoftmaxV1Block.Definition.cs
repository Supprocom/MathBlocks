namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class ProbabilitySoftmaxV1Block
    {
        internal const string Identity = "probability.softmax@1";
        internal static MathBlockOperation Create() => CreateVectorUnary("probability.softmax", MathBlockProbability.Softmax, MathBlockValue.Vector([0d, 0d]), [0.5d, 0.5d], requireDistribution: false, requireDimensionlessInput: true);
    }
}
