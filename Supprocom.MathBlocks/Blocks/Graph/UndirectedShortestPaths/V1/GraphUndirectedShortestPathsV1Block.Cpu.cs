namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static double[] UndirectedShortestPaths(MathBlockGraph graph, int source)
    {
        var distances = MathBlockCollectionPrimitives.Repeat(Math.PositiveInfinity, graph.VertexCount);
        var visited = new bool[graph.VertexCount];
        distances[source] = 0d;
        for (var iteration = 0; iteration < graph.VertexCount; iteration++)
        {
            var vertex = -1;
            var best = Math.PositiveInfinity;
            for (var candidate = 0; candidate < graph.VertexCount; candidate++)
            {
                if (!visited[candidate] && distances[candidate] < best)
                {
                    best = distances[candidate];
                    vertex = candidate;
                }
            }

            if (vertex < 0)
                break;
            visited[vertex] = true;
            foreach (var edge in graph)
            {
                var neighbor = edge.From == vertex ? edge.To : edge.To == vertex ? edge.From : -1;
                if (neighbor < 0)
                    continue;
                distances[neighbor] = Math.Min(distances[neighbor], distances[vertex] + edge.Weight);
            }
        }

        return distances;
    }
}
