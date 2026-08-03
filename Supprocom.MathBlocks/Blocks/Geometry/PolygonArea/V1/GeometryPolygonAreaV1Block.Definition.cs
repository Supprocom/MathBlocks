namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryPolygonAreaV1Block
    {
        internal const string Identity = "geometry.polygon-area@1";
        internal static MathBlockOperation Create() => CreatePointSetScalar("geometry.polygon-area", MathBlockGeometry.PolygonArea, square, 1d, AreaType);
    }
}
