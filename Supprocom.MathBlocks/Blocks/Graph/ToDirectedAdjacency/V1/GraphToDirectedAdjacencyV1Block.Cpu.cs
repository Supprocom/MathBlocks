
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>graph.to-directed-adjacency@1</c> mathematical operation.</summary>
    public static MathBlockMatrix DirectedAdjacencyFromGraph(MathBlockGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);
        var values = new double[graph.VertexCount * graph.VertexCount];
        foreach (var edge in graph)
            values[edge.From * graph.VertexCount + edge.To] += edge.Weight;
        return new MathBlockMatrix(graph.VertexCount, graph.VertexCount, values, true);
    }
}
