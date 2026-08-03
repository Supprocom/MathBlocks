namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationTotalVariationDistanceV1Block
    {
        internal const string Identity = "information.total-variation-distance@1";
        internal static MathBlockOperation Create() => CreateDistributionBinary("information.total-variation-distance", MathBlockProbability.TotalVariationDistance, certain, fair, 0.5d);
    }
}
