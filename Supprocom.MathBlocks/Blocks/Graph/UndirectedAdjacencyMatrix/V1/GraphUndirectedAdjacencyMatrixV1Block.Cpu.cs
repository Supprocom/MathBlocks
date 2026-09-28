namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.undirected-adjacency-matrix@1</c> mathematical operation.</summary>
    public static MathBlockMatrix UndirectedAdjacencyMatrix(MathBlockGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);
        var result = new double[graph.VertexCount * graph.VertexCount];
        foreach (var edge in graph)
        {
            result[edge.From * graph.VertexCount + edge.To] += edge.Weight;
            result[edge.To * graph.VertexCount + edge.From] += edge.Weight;
        }

        return new MathBlockMatrix(graph.VertexCount, graph.VertexCount, result, true);
    }
}
