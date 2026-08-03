namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationShannonEntropyV1Block
    {
        internal const string Identity = "information.shannon-entropy@1";
        internal static MathBlockOperation Create() => CreateScalarUnary("information.shannon-entropy", MathBlockProbability.ShannonEntropy, fair, Math.Log(2d));
    }
}
