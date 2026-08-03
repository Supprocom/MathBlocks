namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static double AlgebraicConnectivity(MathBlockGraph graph)
    {
        if (graph.VertexCount <= 1)
            return 0d;
        return MathBlockLinearAlgebra.SymmetricEigenvalues(UndirectedLaplacian(graph))[1];
    }
}
