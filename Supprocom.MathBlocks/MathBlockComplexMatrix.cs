namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Complex Matrix contract.</summary>
public sealed class MathBlockComplexMatrix
{
    private readonly Complex[] values;

    /// <summary>Copies row-major complex elements into an immutable matrix.</summary>
    public MathBlockComplexMatrix(int rows, int columns, IEnumerable<Complex> values)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(rows);
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(columns);
        ArgumentNullException.ThrowIfNull(values);
        this.values = MathBlockCollectionPrimitives.CopyEnumerable(values);
        if (rows > int.MaxValue / columns || this.values.Length != rows * columns)
            throw new ArgumentException("The complex matrix value count does not match its shape.", nameof(values));
        for (var index = 0; index < this.values.Length; index++)
            if (!MathBlockDataValidation.IsFinite(this.values[index]))
                throw new ArgumentException("A valid complex matrix must contain finite values.", nameof(values));
        Rows = rows;
        Columns = columns;
    }

    internal MathBlockComplexMatrix(int rows, int columns, Complex[] values, bool takeOwnership)
    {
        Rows = rows;
        Columns = columns;
        this.values = takeOwnership ? values : MathBlockCollectionPrimitives.Copy(values);
    }

    /// <summary>Gets the rows value.</summary>
    public int Rows { get; }
    /// <summary>Gets the columns value.</summary>
    public int Columns { get; }
    /// <summary>Gets the value at the specified index.</summary>
    public Complex this[int row, int column] => values[CheckedIndex(row, column)];
    internal ReadOnlySpan<Complex> Span => values;
    /// <summary>Returns a copy of the complex matrix elements in row-major order.</summary>
    public Complex[] ToArray() => MathBlockCollectionPrimitives.Copy(values);

    private int CheckedIndex(int row, int column)
    {
        if ((uint)row >= (uint)Rows)
            throw new ArgumentOutOfRangeException(nameof(row));
        if ((uint)column >= (uint)Columns)
            throw new ArgumentOutOfRangeException(nameof(column));
        return row * Columns + column;
    }
}
