namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static double HodgeResidualNorm(MathBlockGraph graph, IReadOnlyList<double> potential)
    {
        var sumSquares = 0d;
        foreach (var edge in graph)
        {
            var residual = potential[edge.To] - potential[edge.From] - edge.Weight;
            sumSquares += residual * residual;
        }

        return Math.Sqrt(sumSquares);
    }
}
