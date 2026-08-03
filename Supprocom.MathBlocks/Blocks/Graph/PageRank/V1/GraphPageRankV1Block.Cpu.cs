namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static double[] PageRank(MathBlockGraph graph, double damping, int iterations)
    {
        var rank = MathBlockCollectionPrimitives.Repeat(1d / graph.VertexCount, graph.VertexCount);
        var outgoing = new double[graph.VertexCount];
        foreach (var edge in graph)
            outgoing[edge.From] += edge.Weight;
        for (var iteration = 0; iteration < iterations; iteration++)
        {
            var next = MathBlockCollectionPrimitives.Repeat(
                (1d - damping) / graph.VertexCount,
                graph.VertexCount);
            var dangling = 0d;
            for (var vertex = 0; vertex < graph.VertexCount; vertex++)
                if (outgoing[vertex] == 0d)
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
