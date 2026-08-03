namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometrySignedPolygonAreaV1Block
    {
        internal const string Identity = "geometry.signed-polygon-area@1";
        internal static MathBlockOperation Create() => CreatePointSetScalar("geometry.signed-polygon-area", MathBlockGeometry.SignedPolygonArea, square, 1d, AreaType);
    }
}
