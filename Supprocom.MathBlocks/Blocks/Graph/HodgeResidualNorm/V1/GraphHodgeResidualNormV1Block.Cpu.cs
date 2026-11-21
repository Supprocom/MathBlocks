namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.hodge-residual-norm@1</c> mathematical operation.</summary>
    public static float HodgeResidualNorm(MathBlockGraph graph, IReadOnlyList<float> potential)
    {
        ArgumentNullException.ThrowIfNull(graph);
        ArgumentNullException.ThrowIfNull(potential);
        var sumSquares = 0f;
        foreach (var edge in graph)
        {
            var residual = potential[edge.To] - potential[edge.From] - edge.Weight;
            sumSquares += residual * residual;
        }

        return Math.Sqrt(sumSquares);
    }
}
