namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryHalfspaceDepthV1Block
    {
        internal const string Identity = "geometry.halfspace-depth@1";
        internal static MathBlockOperation Create() => CreateHalfspaceDepth();
        private static MathBlockOperation CreateHalfspaceDepth() => MathBlockOperationFactory.Create("geometry.halfspace-depth", 2, types =>
        {
            PointPairLengthType(types);
            return MathBlockType.Scalar();
        }, inputs => inputs[0].AsPointSet().Count > 0 && inputs[1].AsPointSet().Count == 1 ? MathBlockValue.Scalar(MathBlockGeometry.HalfspaceDepth(inputs[0].AsPointSet(), inputs[1].AsPointSet()[0])) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The operation requires a sample and one point."), [square, Singleton(0.5d, 0.5d)], MathBlockValue.Scalar(0.5d), performanceIterations: 4);
    }
}
