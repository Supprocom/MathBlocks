namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationCrossEntropyV1Block
    {
        internal const string Identity = "information.cross-entropy@1";
        internal static MathBlockOperation Create() => CreateDistributionBinary("information.cross-entropy", MathBlockProbability.CrossEntropy, fair, fair, Math.Log(2d), requireReferenceSupport: true);
    }
}
