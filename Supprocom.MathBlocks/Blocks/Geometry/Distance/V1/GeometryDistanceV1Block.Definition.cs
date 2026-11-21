namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryDistanceV1Block
    {
        internal const string Identity = "geometry.distance@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePointPairScalar("geometry.distance", (left, right) => MathBlockGeometry.Distance(left[0], right[0]), Singleton(0f, 0f), Singleton(3f, 4f), 5f);
    }
}
