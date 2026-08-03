
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static MathBlockMatrix DirectedAdjacencyFromGraph(MathBlockGraph graph)
    {
        var values = new double[graph.VertexCount * graph.VertexCount];
        foreach (var edge in graph)
            values[edge.From * graph.VertexCount + edge.To] += edge.Weight;
        return new MathBlockMatrix(graph.VertexCount, graph.VertexCount, values, true);
    }
}
