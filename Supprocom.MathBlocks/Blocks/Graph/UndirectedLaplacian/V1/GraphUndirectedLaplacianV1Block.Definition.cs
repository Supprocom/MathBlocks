namespace Supprocom.MathBlocks;
internal static partial class GraphMathBlocks
{
    internal static class GraphUndirectedLaplacianV1Block
    {
        internal const string Identity = "graph.undirected-laplacian@1";
        internal static MathBlockOperation Create() => CreateMatrix("graph.undirected-laplacian", MathBlockGraphMath.UndirectedLaplacian, path, new MathBlockMatrix(3, 3, [1d, -1d, 0d, -1d, 3d, -2d, 0d, -2d, 2d]));
    }
}
