namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static double[] WeightedDegree(MathBlockGraph graph)
    {
        var result = new double[graph.VertexCount];
        foreach (var edge in graph)
        {
            result[edge.From] += edge.Weight;
            result[edge.To] += edge.Weight;
        }

        return result;
    }
}
