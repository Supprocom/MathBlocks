namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryDistanceV1Block
    {
        internal const string Identity = "geometry.distance@1";
        internal static MathBlockOperation Create() => CreatePointPairScalar("geometry.distance", (left, right) => MathBlockGeometry.Distance(left[0], right[0]), Singleton(0d, 0d), Singleton(3d, 4d), 5d);
    }
}
