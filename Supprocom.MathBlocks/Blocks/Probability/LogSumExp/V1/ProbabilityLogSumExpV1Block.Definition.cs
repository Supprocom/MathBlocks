namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class ProbabilityLogSumExpV1Block
    {
        internal const string Identity = "probability.log-sum-exp@1";
        internal static MathBlockOperation Create() => CreateScalarUnary("probability.log-sum-exp", MathBlockProbability.LogSumExp, MathBlockValue.Vector([0d, 0d]), Math.Log(2d), requireDistribution: false);
    }
}
