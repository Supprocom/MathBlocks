namespace Supprocom.MathBlocks;

internal static partial class GeometryMathBlocks
{
    internal static class GeometryBarycentricCoordinatesV1Block
    {
        internal const string Identity = "geometry.barycentric-coordinates@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateBarycentric();
        private static MathBlockOperation CreateBarycentric() => MathBlockOperationFactory.Create("geometry.barycentric-coordinates", 2, types =>
        {
            PointPairLengthType(types);
            return MathBlockType.Vector(length: 3);
        }, inputs => inputs[0].AsPointSet().Count == 1 && inputs[1].AsPointSet().Count == 3 ? MathBlockValue.Vector(MathBlockGeometry.BarycentricCoordinates(inputs[0].AsPointSet()[0], inputs[1].AsPointSet()[0], inputs[1].AsPointSet()[1], inputs[1].AsPointSet()[2]), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(length: 3), "The operation requires one point and one triangle."), [Singleton(0.25f, 0.25f), MathBlockValue.PointSet(new MathBlockPointSet([new(0f, 0f), new(1f, 0f), new(0f, 1f)]))], MathBlockValue.Vector([0.5f, 0.25f, 0.25f]), performanceIterations: 8);
    }
}
