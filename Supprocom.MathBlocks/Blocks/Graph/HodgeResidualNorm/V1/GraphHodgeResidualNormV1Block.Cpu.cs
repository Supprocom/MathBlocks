namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.hodge-residual-norm@1</c> mathematical operation.</summary>
    public static double HodgeResidualNorm(MathBlockGraph graph, IReadOnlyList<double> potential)
    {
        ArgumentNullException.ThrowIfNull(graph);
        ArgumentNullException.ThrowIfNull(potential);
        var sumSquares = 0d;
        foreach (var edge in graph)
        {
            var residual = potential[edge.To] - potential[edge.From] - edge.Weight;
            sumSquares += residual * residual;
        }

        return Math.Sqrt(sumSquares);
    }
}
