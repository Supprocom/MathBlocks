namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.weighted-degree@1</c> mathematical operation.</summary>
    public static float[] WeightedDegree(MathBlockGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);
        var result = new float[graph.VertexCount];
        foreach (var edge in graph)
        {
            result[edge.From] += edge.Weight;
            result[edge.To] += edge.Weight;
        }

        return result;
    }
}
