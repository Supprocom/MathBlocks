namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class GraphFromDirectedAdjacencyV1Block
    {
        internal const string Identity = "graph.from-directed-adjacency@1";
        internal static MathBlockOperation Create() => CreateGraphFromAdjacency();
        private static MathBlockOperation CreateGraphFromAdjacency() => MathBlockOperationFactory.Create("graph.from-directed-adjacency", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            if (types[0].Rows != 0 && types[0].Columns != 0 && types[0].Rows != types[0].Columns)
                throw new InvalidOperationException("The adjacency matrix must be square.");
            return MathBlockType.Graph(types[0].Unit, types[0].Rows);
        }, inputs => inputs[0].AsMatrix().Rows == inputs[0].AsMatrix().Columns ? MathBlockValue.Graph(MathBlockStructure.DirectedGraphFromAdjacency(inputs[0].AsMatrix()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Graph(inputs[0].Type.Unit), "The adjacency matrix must be square."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 2d, 0d, 0d]))], MathBlockValue.Graph(new MathBlockGraph(2, [new(0, 1, 2d)])), performanceIterations: 16);
    }
}
