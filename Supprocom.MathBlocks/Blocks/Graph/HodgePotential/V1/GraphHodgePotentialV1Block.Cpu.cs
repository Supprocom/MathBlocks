namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static bool TryHodgePotential(MathBlockGraph graph, out double[] potential)
    {
        potential = new double[graph.VertexCount];
        if (graph.VertexCount == 1)
            return true;
        var reducedSize = graph.VertexCount - 1;
        var matrixValues = new double[reducedSize * reducedSize];
        var right = new double[reducedSize];
        foreach (var edge in graph)
        {
            if (edge.From != 0)
            {
                matrixValues[(edge.From - 1) * reducedSize + edge.From - 1] += 1d;
                right[edge.From - 1] -= edge.Weight;
            }

            if (edge.To != 0)
            {
                matrixValues[(edge.To - 1) * reducedSize + edge.To - 1] += 1d;
                right[edge.To - 1] += edge.Weight;
            }

            if (edge.From != 0 && edge.To != 0)
            {
                matrixValues[(edge.From - 1) * reducedSize + edge.To - 1] -= 1d;
                matrixValues[(edge.To - 1) * reducedSize + edge.From - 1] -= 1d;
            }
        }

        if (!MathBlockLinearAlgebra.TrySolve(new MathBlockMatrix(reducedSize, reducedSize, matrixValues, true), right, out var reduced))
            return false;
        for (var index = 0; index < reduced.Length; index++)
            potential[index + 1] = reduced[index];
        return true;
    }
}
