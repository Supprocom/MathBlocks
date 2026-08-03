namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static double[] Degree(MathBlockGraph graph)
    {
        var result = new double[graph.VertexCount];
        foreach (var edge in graph)
        {
            result[edge.From]++;
            result[edge.To]++;
        }

        return result;
    }
}
