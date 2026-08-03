namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphUndirectedShortestPathsV1Block
    {
        internal const string Identity = "graph.undirected-shortest-paths@1";
        internal static MathBlockOperation Create() => CreateShortestPaths();
        private static MathBlockOperation CreateShortestPaths() => MathBlockOperationFactory.Create("graph.undirected-shortest-paths", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            return MathBlockType.Vector(types[0].Unit, types[0].Rows);
        }, inputs =>
        {
            var graph = inputs[0].AsGraph();
            var source = inputs[1].AsScalar();
            if (MathBlockCollectionPrimitives.Any(graph, edge => edge.Weight < 0d) ||
                source != Math.Truncate(source) ||
                source < 0d ||
                source >= graph.VertexCount)
                return MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit, graph.VertexCount), "The graph or source is outside the operation domain.");
            return MathBlockValue.Vector(MathBlockGraphMath.UndirectedShortestPaths(graph, (int)source), inputs[0].Type.Unit, true);
        }, [path, MathBlockValue.Scalar(0d)], MathBlockValue.Vector([0d, 1d, 3d]), performanceIterations: 4);
    }
}
