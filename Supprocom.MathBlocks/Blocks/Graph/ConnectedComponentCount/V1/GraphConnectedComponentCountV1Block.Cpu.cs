using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{
    /// <summary>Computes the <c>graph.connected-component-count@1</c> mathematical operation.</summary>
    public static int ConnectedComponentCount(MathBlockGraph graph)
    {
        ArgumentNullException.ThrowIfNull(graph);
        var adjacency = CreateUndirectedAdjacency(graph);
        var visited = new bool[graph.VertexCount];
        var components = 0;
        var queue = new int[graph.VertexCount];
        for (var start = 0; start < graph.VertexCount; start++)
        {
            if (visited[start])
                continue;
            components++;
            var head = 0;
            var tail = 0;
            queue[tail++] = start;
            visited[start] = true;
            while (head < tail)
            {
                var vertex = queue[head++];
                foreach (ref readonly var neighbor in CollectionsMarshal.AsSpan(adjacency[vertex]))
                {
                    if (visited[neighbor])
                        continue;
                    visited[neighbor] = true;
                    queue[tail++] = neighbor;
                }
            }
        }

        return components;
    }
}
