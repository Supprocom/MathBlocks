namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.triangle-count@1</c> mathematical operation.</summary>
    public static int TriangleCount(MathBlockGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);
        var adjacency = new bool[graph.VertexCount * graph.VertexCount];
        foreach (var edge in graph)
            adjacency[edge.From * graph.VertexCount + edge.To] = adjacency[edge.To * graph.VertexCount + edge.From] = true;
        var count = 0;
        for (var first = 0; first < graph.VertexCount; first++)
            for (var second = first + 1; second < graph.VertexCount; second++)
                for (var third = second + 1; third < graph.VertexCount; third++)
                    if (adjacency[first * graph.VertexCount + second] && adjacency[first * graph.VertexCount + third] && adjacency[second * graph.VertexCount + third])
                        count++;
        return count;
    }
}
