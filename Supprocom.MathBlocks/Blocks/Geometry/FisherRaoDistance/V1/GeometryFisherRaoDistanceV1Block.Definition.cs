namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class GeometryFisherRaoDistanceV1Block
    {
        internal const string Identity = "geometry.fisher-rao-distance@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreatePositiveVectorMetric("geometry.fisher-rao-distance", MathBlockAdvanced.FisherRaoDistance, MathBlockValue.Vector([0.5f, 0.5f]), MathBlockValue.Vector([1f, 0f]), Math.PI / 2f, distribution: true);
    }
}
