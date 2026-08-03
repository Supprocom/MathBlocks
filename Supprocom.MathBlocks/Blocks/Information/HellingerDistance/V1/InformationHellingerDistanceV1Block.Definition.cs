namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationHellingerDistanceV1Block
    {
        internal const string Identity = "information.hellinger-distance@1";
        internal static MathBlockOperation Create() => CreateDistributionBinary("information.hellinger-distance", MathBlockProbability.HellingerDistance, certain, fair, Math.Sqrt(1d - 1d / Math.Sqrt(2d)));
    }
}
