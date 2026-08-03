namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryDiameterV1Block
    {
        internal const string Identity = "geometry.diameter@1";
        internal static MathBlockOperation Create() => CreatePointSetScalar("geometry.diameter", MathBlockGeometry.Diameter, MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(3d, 4d)])), 5d, LengthType);
    }
}
