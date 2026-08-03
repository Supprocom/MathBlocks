namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryCircumradiusV1Block
    {
        internal const string Identity = "geometry.circumradius@1";
        internal static MathBlockOperation Create() => CreateCircumradius();
        private static MathBlockOperation CreateCircumradius() => MathBlockOperationFactory.Create("geometry.circumradius", 1, LengthType, inputs => inputs[0].AsPointSet().Count == 3 ? MathBlockValue.Scalar(MathBlockGeometry.Circumradius(inputs[0].AsPointSet()[0], inputs[0].AsPointSet()[1], inputs[0].AsPointSet()[2]), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The operation requires one triangle."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(0d, 1d)]))], MathBlockValue.Scalar(Math.Sqrt(0.5d)), 1e-9, 8);
    }
}
