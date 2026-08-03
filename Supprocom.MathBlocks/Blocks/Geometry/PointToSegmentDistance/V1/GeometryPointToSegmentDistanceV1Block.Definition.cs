namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryPointToSegmentDistanceV1Block
    {
        internal const string Identity = "geometry.point-to-segment-distance@1";
        internal static MathBlockOperation Create() => CreatePointToSegment();
        private static MathBlockOperation CreatePointToSegment() => MathBlockOperationFactory.Create("geometry.point-to-segment-distance", 2, PointPairLengthType, inputs => inputs[0].AsPointSet().Count == 1 && inputs[1].AsPointSet().Count == 2 ? MathBlockValue.Scalar(MathBlockGeometry.PointToSegmentDistance(inputs[0].AsPointSet()[0], inputs[1].AsPointSet()[0], inputs[1].AsPointSet()[1]), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "The operation requires one point and one segment."), [Singleton(1d, 1d), MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(2d, 0d)]))], MathBlockValue.Scalar(1d), performanceIterations: 8);
    }
}
