namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.degree@1</c> mathematical operation.</summary>
    public static float[] Degree(MathBlockGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);
        var result = new float[graph.VertexCount];
        foreach (var edge in graph)
        {
            result[edge.From]++;
            result[edge.To]++;
        }

        return result;
    }
}
