namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class GeometryFisherRaoDistanceV1Block
    {
        internal const string Identity = "geometry.fisher-rao-distance@1";
        internal static MathBlockOperation Create() => CreatePositiveVectorMetric("geometry.fisher-rao-distance", MathBlockAdvanced.FisherRaoDistance, MathBlockValue.Vector([0.5d, 0.5d]), MathBlockValue.Vector([1d, 0d]), Math.PI / 2d, distribution: true);
    }
}
