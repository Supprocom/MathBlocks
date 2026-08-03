namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryBarycentricCoordinatesV1Block
    {
        internal const string Identity = "geometry.barycentric-coordinates@1";
        internal static MathBlockOperation Create() => CreateBarycentric();
        private static MathBlockOperation CreateBarycentric() => MathBlockOperationFactory.Create("geometry.barycentric-coordinates", 2, types =>
        {
            PointPairLengthType(types);
            return MathBlockType.Vector(length: 3);
        }, inputs => inputs[0].AsPointSet().Count == 1 && inputs[1].AsPointSet().Count == 3 ? MathBlockValue.Vector(MathBlockGeometry.BarycentricCoordinates(inputs[0].AsPointSet()[0], inputs[1].AsPointSet()[0], inputs[1].AsPointSet()[1], inputs[1].AsPointSet()[2]), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(length: 3), "The operation requires one point and one triangle."), [Singleton(0.25d, 0.25d), MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(0d, 1d)]))], MathBlockValue.Vector([0.5d, 0.25d, 0.25d]), performanceIterations: 8);
    }
}
