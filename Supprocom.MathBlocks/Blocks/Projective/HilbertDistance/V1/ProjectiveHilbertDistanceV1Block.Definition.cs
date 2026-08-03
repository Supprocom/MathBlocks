namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class ProjectiveHilbertDistanceV1Block
    {
        internal const string Identity = "projective.hilbert-distance@1";
        internal static MathBlockOperation Create() => CreatePositiveVectorMetric("projective.hilbert-distance", MathBlockAdvanced.HilbertProjectiveDistance, MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([1d, 1d]), Math.Log(2d), distribution: false);
    }
}
