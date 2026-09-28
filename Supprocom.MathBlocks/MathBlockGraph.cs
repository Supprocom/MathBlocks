using System.Collections;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Graph contract.</summary>
public sealed class MathBlockGraph : IReadOnlyList<MathBlockGraphEdge>
{
    private readonly MathBlockGraphEdge[] edges;

    /// <summary>Creates a graph with a fixed vertex count and copied edges.</summary>
    public MathBlockGraph(int vertexCount, IEnumerable<MathBlockGraphEdge> edges)
    {
        ArgumentOutOfRangeException.ThrowIfNegative(vertexCount);
        ArgumentNullException.ThrowIfNull(edges);
        VertexCount = vertexCount;
        this.edges = MathBlockCollectionPrimitives.CopyEnumerable(edges);
        for (var index = 0; index < this.edges.Length; index++)
            this.edges[index] = this.edges[index].Validate(vertexCount);
    }

    /// <summary>Gets the vertex count value.</summary>
    public int VertexCount { get; }
    /// <summary>Gets the count value.</summary>
    public int Count => edges.Length;
    /// <summary>Gets the value at the specified index.</summary>
    public MathBlockGraphEdge this[int index] => edges[index];
    internal ReadOnlySpan<MathBlockGraphEdge> Span => edges;
    /// <summary>Returns a copy of the graph edges.</summary>
    public MathBlockGraphEdge[] ToArray() => MathBlockCollectionPrimitives.Copy(edges);
    /// <summary>Enumerates the contained values.</summary>
    public IEnumerator<MathBlockGraphEdge> GetEnumerator() => ((IEnumerable<MathBlockGraphEdge>)edges).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => edges.GetEnumerator();
}
