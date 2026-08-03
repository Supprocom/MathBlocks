namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationKullbackLeiblerV1Block
    {
        internal const string Identity = "information.kullback-leibler@1";
        internal static MathBlockOperation Create() => CreateDistributionBinary("information.kullback-leibler", MathBlockProbability.KullbackLeiblerDivergence, certain, fair, Math.Log(2d), requireReferenceSupport: true);
    }
}
