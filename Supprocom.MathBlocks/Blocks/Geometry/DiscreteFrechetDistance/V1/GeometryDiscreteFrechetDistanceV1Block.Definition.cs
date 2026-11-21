namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryDiscreteFrechetDistanceV1Block
    {
        internal const string Identity = "geometry.discrete-frechet-distance@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePointPairScalar("geometry.discrete-frechet-distance", MathBlockGeometry.DiscreteFrechetDistance, MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 0f), new(1f, 0f)])), MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 1f), new(1f, 1f)])), 1f);
    }
}
