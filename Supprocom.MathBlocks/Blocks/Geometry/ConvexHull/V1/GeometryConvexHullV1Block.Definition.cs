namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryConvexHullV1Block
    {
        internal const string Identity = "geometry.convex-hull@1";
        internal static MathBlockOperation Create() => CreateConvexHull();
        private static MathBlockOperation CreateConvexHull() => MathBlockOperationFactory.Create("geometry.convex-hull", 1, SamePointSet, inputs => inputs[0].AsPointSet().Count > 0 ? MathBlockValue.PointSet(new MathBlockPointSet(MathBlockGeometry.ConvexHull(inputs[0].AsPointSet())), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.PointSet(inputs[0].Type.Unit), "The point set is empty."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(0.5d, 0.5d), new(1d, 1d), new(0d, 1d)]))], square, performanceIterations: 4);
    }
}
