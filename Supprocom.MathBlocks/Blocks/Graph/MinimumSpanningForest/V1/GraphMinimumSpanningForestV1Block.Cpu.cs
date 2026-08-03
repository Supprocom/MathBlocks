namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    public static MathBlockGraph MinimumSpanningForest(MathBlockGraph graph)
    {
        var parent = MathBlockCollectionPrimitives.Range(graph.VertexCount);
        var rank = new byte[graph.VertexCount];
        var selected = new List<MathBlockGraphEdge>();
        var edges = MathBlockCollectionPrimitives.SortedCopy(
            graph,
            (left, right) =>
            {
                if (left.Weight < right.Weight)
                    return -1;
                if (left.Weight > right.Weight)
                    return 1;
                if (left.From != right.From)
                    return left.From.CompareTo(right.From);
                return left.To.CompareTo(right.To);
            });
        for (var edgeIndex = 0; edgeIndex < edges.Length; edgeIndex++)
        {
            var edge = edges[edgeIndex];
            var left = Find(parent, edge.From);
            var right = Find(parent, edge.To);
            if (left == right)
                continue;
            if (rank[left] < rank[right])
                parent[left] = right;
            else if (rank[left] > rank[right])
                parent[right] = left;
            else
            {
                parent[right] = left;
                rank[left]++;
            }

            selected.Add(edge);
        }

        return new MathBlockGraph(graph.VertexCount, selected);
    }
}
