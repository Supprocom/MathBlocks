namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphPageRankV1Block
    {
        internal const string Identity = "graph.page-rank@1";
        internal static MathBlockOperation Create() => CreatePageRank();
        private static MathBlockOperation CreatePageRank() => MathBlockOperationFactory.Create("graph.page-rank", 3, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            MathBlockTypeRules.RequireDimensionless(types[2]);
            return MathBlockType.Vector(length: types[0].Rows);
        }, inputs =>
        {
            var graph = inputs[0].AsGraph();
            var damping = inputs[1].AsScalar();
            var iterations = inputs[2].AsScalar();
            return MathBlockCollectionPrimitives.Any(graph, edge => edge.Weight < 0d) ||
                   damping is < 0d or > 1d ||
                   iterations != Math.Truncate(iterations) ||
                   iterations < 1d ||
                   iterations > 10_000d
                ? MathBlockValue.Invalid(
                    MathBlockType.Vector(length: graph.VertexCount),
                    "The inputs are outside the operation domain.")
                : MathBlockValue.Vector(
                    MathBlockGraphMath.PageRank(graph, damping, (int)iterations),
                    default,
                    true);
        }, [MathBlockValue.Graph(new MathBlockGraph(2, [new(0, 1, 1d), new(1, 0, 1d)])), MathBlockValue.Scalar(0.85d), MathBlockValue.Scalar(20d)], MathBlockValue.Vector([0.5d, 0.5d]), 1e-9, 2);
    }
}
