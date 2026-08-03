namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryCentroidV1Block
    {
        internal const string Identity = "geometry.centroid@1";
        internal static MathBlockOperation Create() => CreateCentroid();
        private static MathBlockOperation CreateCentroid() => MathBlockOperationFactory.Create("geometry.centroid", 1, SamePointSet, inputs => inputs[0].AsPointSet().Count > 0 ? MathBlockValue.PointSet(new MathBlockPointSet([MathBlockGeometry.Centroid(inputs[0].AsPointSet())]), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.PointSet(inputs[0].Type.Unit), "The point set is empty."), [square], Singleton(0.5d, 0.5d), performanceIterations: 8);
    }
}
