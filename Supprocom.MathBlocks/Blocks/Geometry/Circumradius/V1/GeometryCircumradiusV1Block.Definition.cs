namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryCircumradiusV1Block
    {
        internal const string Identity = "geometry.circumradius@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateCircumradius();
        private static MathBlockOperation CreateCircumradius() => MathBlockOperationFactory.Create("geometry.circumradius", 1, LengthType, inputs => inputs[0].AsPointSet().Count == 3 ? MathBlockValue.Scalar(MathBlockGeometry.Circumradius(inputs[0].AsPointSet()[0], inputs[0].AsPointSet()[1], inputs[0].AsPointSet()[2]), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The operation requires one triangle."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 0f), new(1f, 0f), new(0f, 1f)]))], MathBlockValue.Scalar(Math.Sqrt(0.5f)), 1e-9f, 8);
    }
}
