namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class ProjectiveHilbertDistanceV1Block
    {
        internal const string Identity = "projective.hilbert-distance@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreatePositiveVectorMetric("projective.hilbert-distance", MathBlockAdvanced.HilbertProjectiveDistance, MathBlockValue.Vector([1f, 2f]), MathBlockValue.Vector([1f, 1f]), Math.Log(2f), distribution: false);
    }
}
