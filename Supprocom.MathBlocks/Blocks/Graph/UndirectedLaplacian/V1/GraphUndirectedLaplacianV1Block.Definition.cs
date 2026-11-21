namespace Supprocom.MathBlocks;

internal static partial class GraphMathBlocks
{
    internal static class GraphUndirectedLaplacianV1Block
    {
        internal const string Identity = "graph.undirected-laplacian@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreateMatrix("graph.undirected-laplacian", MathBlockGraphMath.UndirectedLaplacian, path, new MathBlockMatrix(3, 3, [1f, -1f, 0f, -1f, 3f, -2f, 0f, -2f, 2f]));
    }
}
