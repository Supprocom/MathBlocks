namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryPerimeterV1Block
    {
        internal const string Identity = "geometry.perimeter@1";
        internal static MathBlockOperation Create() => CreatePointSetScalar("geometry.perimeter", MathBlockGeometry.Perimeter, square, 4d, LengthType);
    }
}
