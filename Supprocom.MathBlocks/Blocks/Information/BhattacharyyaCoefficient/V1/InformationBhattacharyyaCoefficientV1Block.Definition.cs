namespace Supprocom.MathBlocks;
internal static partial class ProbabilityMathBlocks
{
    internal static class InformationBhattacharyyaCoefficientV1Block
    {
        internal const string Identity = "information.bhattacharyya-coefficient@1";
        internal static MathBlockOperation Create() => CreateDistributionBinary("information.bhattacharyya-coefficient", MathBlockProbability.BhattacharyyaCoefficient, certain, fair, 1d / Math.Sqrt(2d));
    }
}
