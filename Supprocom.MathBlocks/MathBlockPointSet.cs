using System.Collections;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Point Set contract.</summary>
public sealed class MathBlockPointSet : IReadOnlyList<MathBlockPoint>
{
    private readonly MathBlockPoint[] points;

    /// <summary>Copies points into an immutable point set.</summary>
    public MathBlockPointSet(IEnumerable<MathBlockPoint> points)
    {
        ArgumentNullException.ThrowIfNull(points);
        this.points = MathBlockCollectionPrimitives.CopyEnumerable(points);
        for (var index = 0; index < this.points.Length; index++)
            this.points[index] = this.points[index].Validate();
    }

    internal MathBlockPointSet(MathBlockPoint[] points, bool takeOwnership) =>
        this.points = takeOwnership ? points : MathBlockCollectionPrimitives.Copy(points);

    /// <summary>Gets the count value.</summary>
    public int Count => points.Length;
    /// <summary>Gets the value at the specified index.</summary>
    public MathBlockPoint this[int index] => points[index];
    internal ReadOnlySpan<MathBlockPoint> Span => points;
    /// <summary>Returns a copy of the points.</summary>
    public MathBlockPoint[] ToArray() => MathBlockCollectionPrimitives.Copy(points);
    /// <summary>Enumerates the contained values.</summary>
    public IEnumerator<MathBlockPoint> GetEnumerator() => ((IEnumerable<MathBlockPoint>)points).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => points.GetEnumerator();
}
