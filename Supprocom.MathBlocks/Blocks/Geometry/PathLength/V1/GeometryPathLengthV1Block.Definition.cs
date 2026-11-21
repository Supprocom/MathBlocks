namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryPathLengthV1Block
    {
        internal const string Identity = "geometry.path-length@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePointSetScalar("geometry.path-length", MathBlockGeometry.PathLength, MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 0f), new(3f, 4f)])), 5f, LengthType);
    }
}
