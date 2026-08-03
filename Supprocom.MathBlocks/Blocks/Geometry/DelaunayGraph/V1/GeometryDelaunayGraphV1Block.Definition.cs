namespace Supprocom.MathBlocks;
internal static partial class GeometryMathBlocks
{
    internal static class GeometryDelaunayGraphV1Block
    {
        internal const string Identity = "geometry.delaunay-graph@1";
        internal static MathBlockOperation Create() => CreateDelaunay();
        private static MathBlockOperation CreateDelaunay() => MathBlockOperationFactory.Create("geometry.delaunay-graph", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
            return MathBlockType.Graph(types[0].Unit, types[0].Rows);
        }, inputs => inputs[0].AsPointSet().Count >= 2 ? MathBlockValue.Graph(MathBlockGeometry.DelaunayGraph(inputs[0].AsPointSet()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Graph(inputs[0].Type.Unit), "The operation requires at least two points."), [MathBlockValue.PointSet(new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(0d, 1d)]))], MathBlockValue.Graph(new MathBlockGraph(3, [new(0, 1, 1d), new(0, 2, 1d), new(1, 2, Math.Sqrt(2d))])), 1e-9, 2);
    }
}
