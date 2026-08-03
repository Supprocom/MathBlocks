namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class GraphToDirectedAdjacencyV1Block
    {
        internal const string Identity = "graph.to-directed-adjacency@1";
        internal static MathBlockOperation Create() => CreateAdjacencyFromGraph();
        private static MathBlockOperation CreateAdjacencyFromGraph() => MathBlockOperationFactory.Create("graph.to-directed-adjacency", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
            return MathBlockType.Matrix(types[0].Unit, types[0].Rows, types[0].Rows);
        }, inputs => MathBlockValue.Matrix(MathBlockStructure.DirectedAdjacencyFromGraph(inputs[0].AsGraph()), inputs[0].Type.Unit), [MathBlockValue.Graph(new MathBlockGraph(2, [new(0, 1, 2d)]))], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 2d, 0d, 0d])), performanceIterations: 16);
    }
}
