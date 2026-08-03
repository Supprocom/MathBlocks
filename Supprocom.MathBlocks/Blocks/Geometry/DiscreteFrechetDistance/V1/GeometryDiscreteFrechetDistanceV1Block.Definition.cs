namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryDiscreteFrechetDistanceV1Block
    {
        internal const string Identity = "geometry.discrete-frechet-distance@1";
        internal static MathBlockOperation Create() => CreatePointPairScalar("geometry.discrete-frechet-distance", MathBlockGeometry.DiscreteFrechetDistance, MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d)])), MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 1d), new(1d, 1d)])), 1d);
    }
}
