using System.Collections;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Boolean Vector contract.</summary>
public sealed class MathBlockBooleanVector : IReadOnlyList<bool>
{
    private readonly bool[] values;

    /// <summary>Copies Boolean elements into an immutable vector.</summary>
    public MathBlockBooleanVector(IEnumerable<bool> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        this.values = MathBlockCollectionPrimitives.CopyEnumerable(values);
    }

    internal MathBlockBooleanVector(bool[] values, bool takeOwnership) =>
        this.values = takeOwnership ? values : MathBlockCollectionPrimitives.Copy(values);

    /// <summary>Gets the count value.</summary>
    public int Count => values.Length;
    /// <summary>Gets the value at the specified index.</summary>
    public bool this[int index] => values[index];
    internal ReadOnlySpan<bool> Span => values;
    /// <summary>Returns a copy of the Boolean vector elements.</summary>
    public bool[] ToArray() => MathBlockCollectionPrimitives.Copy(values);
    /// <summary>Enumerates the contained values.</summary>
    public IEnumerator<bool> GetEnumerator() => ((IEnumerable<bool>)values).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => values.GetEnumerator();
}
