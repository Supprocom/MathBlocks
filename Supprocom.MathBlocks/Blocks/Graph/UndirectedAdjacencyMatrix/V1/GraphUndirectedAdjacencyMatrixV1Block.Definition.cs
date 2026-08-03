namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphUndirectedAdjacencyMatrixV1Block
    {
        internal const string Identity = "graph.undirected-adjacency-matrix@1";
        internal static MathBlockOperation Create() => CreateMatrix("graph.undirected-adjacency-matrix", MathBlockGraphMath.UndirectedAdjacencyMatrix, path, new MathBlockMatrix(3, 3, [0d, 1d, 0d, 1d, 0d, 2d, 0d, 2d, 0d]));
    }
}
