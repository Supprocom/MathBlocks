namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryHausdorffDistanceV1Block
    {
        internal const string Identity = "geometry.hausdorff-distance@1";
        internal static MathBlockOperation Create() => CreatePointPairScalar("geometry.hausdorff-distance", MathBlockGeometry.HausdorffDistance, MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d)])), MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 1d), new(1d, 1d)])), 1d);
    }
}
