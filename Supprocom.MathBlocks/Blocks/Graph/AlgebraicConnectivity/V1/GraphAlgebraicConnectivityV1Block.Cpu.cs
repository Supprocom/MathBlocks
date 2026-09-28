namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Graph Math contract.</summary>
public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.algebraic-connectivity@1</c> mathematical operation.</summary>
    public static double AlgebraicConnectivity(MathBlockGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);
        if (graph.VertexCount <= 1)
            return 0d;
        return MathBlockLinearAlgebra.SymmetricEigenvalues(UndirectedLaplacian(graph))[1];
    }
}
