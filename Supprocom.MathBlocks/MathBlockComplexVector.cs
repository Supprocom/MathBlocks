using System.Collections;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Complex Vector contract.</summary>
public sealed class MathBlockComplexVector : IReadOnlyList<Complex>
{
    private readonly Complex[] values;

    /// <summary>Copies finite complex elements into an immutable vector.</summary>
    public MathBlockComplexVector(IEnumerable<Complex> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        this.values = MathBlockCollectionPrimitives.CopyEnumerable(values);
        for (var index = 0; index < this.values.Length; index++)
            if (!MathBlockDataValidation.IsFinite(this.values[index]))
                throw new ArgumentException("A valid complex vector must contain finite values.", nameof(values));
    }

    internal MathBlockComplexVector(Complex[] values, bool takeOwnership) =>
        this.values = takeOwnership ? values : MathBlockCollectionPrimitives.Copy(values);

    /// <summary>Gets the count value.</summary>
    public int Count => values.Length;
    /// <summary>Gets the value at the specified index.</summary>
    public Complex this[int index] => values[index];
    internal ReadOnlySpan<Complex> Span => values;
    /// <summary>Returns a copy of the complex vector elements.</summary>
    public Complex[] ToArray() => MathBlockCollectionPrimitives.Copy(values);
    /// <summary>Enumerates the contained values.</summary>
    public IEnumerator<Complex> GetEnumerator() => ((IEnumerable<Complex>)values).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => values.GetEnumerator();
}
