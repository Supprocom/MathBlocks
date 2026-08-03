namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryPathLengthV1Block
    {
        internal const string Identity = "geometry.path-length@1";
        internal static MathBlockOperation Create() => CreatePointSetScalar("geometry.path-length", MathBlockGeometry.PathLength, MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(3d, 4d)])), 5d, LengthType);
    }
}
