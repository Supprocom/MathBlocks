namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryHausdorffDistanceV1Block
    {
        internal const string Identity = "geometry.hausdorff-distance@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePointPairScalar("geometry.hausdorff-distance", MathBlockGeometry.HausdorffDistance, MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 0f), new(1f, 0f)])), MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 1f), new(1f, 1f)])), 1f);
    }
}
