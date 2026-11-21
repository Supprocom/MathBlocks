namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.page-rank@1</c> mathematical operation.</summary>
    public static float[] PageRank(MathBlockGraph graph, float damping, int iterations)
    {
        ArgumentNullException.ThrowIfNull(graph);
        var rank = MathBlockCollectionPrimitives.Repeat(1f / graph.VertexCount, graph.VertexCount);
        var outgoing = new float[graph.VertexCount];
        foreach (var edge in graph)
            outgoing[edge.From] += edge.Weight;
        for (var iteration = 0; iteration < iterations; iteration++)
        {
            var next = MathBlockCollectionPrimitives.Repeat(
                (1f - damping) / graph.VertexCount,
                graph.VertexCount);
            var dangling = 0f;
            for (var vertex = 0; vertex < graph.VertexCount; vertex++)
                if (outgoing[vertex] == 0f)
                    dangling += rank[vertex];
            var danglingShare = damping * dangling / graph.VertexCount;
            for (var vertex = 0; vertex < graph.VertexCount; vertex++)
                next[vertex] += danglingShare;
            foreach (var edge in graph)
                next[edge.To] += damping * rank[edge.From] * edge.Weight / outgoing[edge.From];
            rank = next;
        }

        return rank;
    }
}
