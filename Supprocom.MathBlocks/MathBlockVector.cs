using System.Collections;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Vector contract.</summary>
public sealed class MathBlockVector : IReadOnlyList<float>
{
    private readonly float[] values;

    /// <summary>Copies finite elements into an immutable vector.</summary>
    public MathBlockVector(IEnumerable<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        this.values = MathBlockCollectionPrimitives.CopyEnumerable(values);
        for (var index = 0; index < this.values.Length; index++)
            if (!Math.IsFinite(this.values[index]))
                throw new ArgumentException("A valid vector must contain finite values.", nameof(values));
    }

    internal MathBlockVector(float[] values, bool takeOwnership)
    {
        this.values = takeOwnership ? values : MathBlockCollectionPrimitives.Copy(values);
    }

    /// <summary>Gets the count value.</summary>
    public int Count => values.Length;
    /// <summary>Gets the value at the specified index.</summary>
    public float this[int index] => values[index];
    internal ReadOnlySpan<float> Span => values;
    /// <summary>Returns a copy of the vector elements.</summary>
    public float[] ToArray() => MathBlockCollectionPrimitives.Copy(values);
    /// <summary>Enumerates the contained values.</summary>
    public IEnumerator<float> GetEnumerator() => ((IEnumerable<float>)values).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => values.GetEnumerator();
}
