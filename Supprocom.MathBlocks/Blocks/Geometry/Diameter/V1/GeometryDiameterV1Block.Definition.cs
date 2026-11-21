namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryDiameterV1Block
    {
        internal const string Identity = "geometry.diameter@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePointSetScalar("geometry.diameter", MathBlockGeometry.Diameter, MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 0f), new(3f, 4f)])), 5f, LengthType);
    }
}
