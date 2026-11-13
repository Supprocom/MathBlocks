namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Graph Math contract.</summary>
public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.algebraic-connectivity@1</c> mathematical operation.</summary>
    public static double AlgebraicConnectivity(MathBlockGraph graph) => AlgebraicConnectivity(graph, MathBlockDomainContext.Default) ?? double.NaN;

    // The second eigenvalue of the Laplacian under the context's Jacobi options, or null under the Invalid policy when Jacobi
    // stopped at its budget.
    internal static double? AlgebraicConnectivity(MathBlockGraph graph, MathBlockDomainContext domain)
    {
        ArgumentNullException.ThrowIfNull(graph);
        if (graph.VertexCount <= 1)
            return 0d;
        return MathBlockLinearAlgebra.SymmetricEigenvalues(UndirectedLaplacian(graph), domain)?[1];
    }
}
