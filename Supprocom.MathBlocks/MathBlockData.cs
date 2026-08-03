using System.Collections;

namespace Supprocom.MathBlocks;

public sealed class MathBlockVector : IReadOnlyList<double>
{
    private readonly double[] values;

    public MathBlockVector(IEnumerable<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        this.values = MathBlockCollectionPrimitives.CopyEnumerable(values);
        for (var index = 0; index < this.values.Length; index++)
            if (!Math.IsFinite(this.values[index]))
                throw new ArgumentException("A valid vector must contain finite values.", nameof(values));
    }

    internal MathBlockVector(double[] values, bool takeOwnership)
    {
        this.values = takeOwnership ? values : MathBlockCollectionPrimitives.Copy(values);
    }

    public int Count => values.Length;
    public double this[int index] => values[index];
    internal ReadOnlySpan<double> Span => values;
    public double[] ToArray() => MathBlockCollectionPrimitives.Copy(values);
    public IEnumerator<double> GetEnumerator() => ((IEnumerable<double>)values).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => values.GetEnumerator();
}

public sealed class MathBlockComplexVector : IReadOnlyList<Complex>
{
    private readonly Complex[] values;

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

    public int Count => values.Length;
    public Complex this[int index] => values[index];
    internal ReadOnlySpan<Complex> Span => values;
    public Complex[] ToArray() => MathBlockCollectionPrimitives.Copy(values);
    public IEnumerator<Complex> GetEnumerator() => ((IEnumerable<Complex>)values).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => values.GetEnumerator();
}

public sealed class MathBlockBooleanVector : IReadOnlyList<bool>
{
    private readonly bool[] values;

    public MathBlockBooleanVector(IEnumerable<bool> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        this.values = MathBlockCollectionPrimitives.CopyEnumerable(values);
    }

    internal MathBlockBooleanVector(bool[] values, bool takeOwnership) =>
        this.values = takeOwnership ? values : MathBlockCollectionPrimitives.Copy(values);

    public int Count => values.Length;
    public bool this[int index] => values[index];
    internal ReadOnlySpan<bool> Span => values;
    public bool[] ToArray() => MathBlockCollectionPrimitives.Copy(values);
    public IEnumerator<bool> GetEnumerator() => ((IEnumerable<bool>)values).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => values.GetEnumerator();
}

public sealed class MathBlockMatrix
{
    private readonly double[] values;

    public MathBlockMatrix(int rows, int columns, IEnumerable<double> values)
    {
        if (rows <= 0)
            throw new ArgumentOutOfRangeException(nameof(rows));
        if (columns <= 0)
            throw new ArgumentOutOfRangeException(nameof(columns));
        ArgumentNullException.ThrowIfNull(values);
        this.values = MathBlockCollectionPrimitives.CopyEnumerable(values);
        if (rows > int.MaxValue / columns || this.values.Length != rows * columns)
            throw new ArgumentException("The matrix value count does not match its shape.", nameof(values));
        for (var index = 0; index < this.values.Length; index++)
            if (!Math.IsFinite(this.values[index]))
                throw new ArgumentException("A valid matrix must contain finite values.", nameof(values));
        Rows = rows;
        Columns = columns;
    }

    internal MathBlockMatrix(int rows, int columns, double[] values, bool takeOwnership)
    {
        Rows = rows;
        Columns = columns;
        this.values = takeOwnership ? values : MathBlockCollectionPrimitives.Copy(values);
    }

    public int Rows { get; }
    public int Columns { get; }
    public double this[int row, int column] => values[CheckedIndex(row, column)];
    internal ReadOnlySpan<double> Span => values;
    public double[] ToArray() => MathBlockCollectionPrimitives.Copy(values);

    private int CheckedIndex(int row, int column)
    {
        if ((uint)row >= (uint)Rows)
            throw new ArgumentOutOfRangeException(nameof(row));
        if ((uint)column >= (uint)Columns)
            throw new ArgumentOutOfRangeException(nameof(column));
        return row * Columns + column;
    }
}

public sealed class MathBlockComplexMatrix
{
    private readonly Complex[] values;

    public MathBlockComplexMatrix(int rows, int columns, IEnumerable<Complex> values)
    {
        if (rows <= 0)
            throw new ArgumentOutOfRangeException(nameof(rows));
        if (columns <= 0)
            throw new ArgumentOutOfRangeException(nameof(columns));
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

    public int Rows { get; }
    public int Columns { get; }
    public Complex this[int row, int column] => values[CheckedIndex(row, column)];
    internal ReadOnlySpan<Complex> Span => values;
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

public readonly record struct MathBlockPoint(double X, double Y)
{
    public MathBlockPoint Validate()
    {
        if (!Math.IsFinite(X) || !Math.IsFinite(Y))
            throw new InvalidDataException("A point must contain finite coordinates.");
        return this;
    }
}

public sealed class MathBlockPointSet : IReadOnlyList<MathBlockPoint>
{
    private readonly MathBlockPoint[] points;

    public MathBlockPointSet(IEnumerable<MathBlockPoint> points)
    {
        ArgumentNullException.ThrowIfNull(points);
        this.points = MathBlockCollectionPrimitives.CopyEnumerable(points);
        for (var index = 0; index < this.points.Length; index++)
            this.points[index] = this.points[index].Validate();
    }

    internal MathBlockPointSet(MathBlockPoint[] points, bool takeOwnership) =>
        this.points = takeOwnership ? points : MathBlockCollectionPrimitives.Copy(points);

    public int Count => points.Length;
    public MathBlockPoint this[int index] => points[index];
    internal ReadOnlySpan<MathBlockPoint> Span => points;
    public MathBlockPoint[] ToArray() => MathBlockCollectionPrimitives.Copy(points);
    public IEnumerator<MathBlockPoint> GetEnumerator() => ((IEnumerable<MathBlockPoint>)points).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => points.GetEnumerator();
}

public readonly record struct MathBlockGraphEdge(int From, int To, double Weight)
{
    public MathBlockGraphEdge Validate(int vertexCount)
    {
        if ((uint)From >= (uint)vertexCount || (uint)To >= (uint)vertexCount)
            throw new InvalidDataException("A graph edge has invalid vertices.");
        if (!Math.IsFinite(Weight))
            throw new InvalidDataException("A graph edge must have a finite weight.");
        return this;
    }
}

public sealed class MathBlockGraph : IReadOnlyList<MathBlockGraphEdge>
{
    private readonly MathBlockGraphEdge[] edges;

    public MathBlockGraph(int vertexCount, IEnumerable<MathBlockGraphEdge> edges)
    {
        if (vertexCount < 0)
            throw new ArgumentOutOfRangeException(nameof(vertexCount));
        ArgumentNullException.ThrowIfNull(edges);
        VertexCount = vertexCount;
        this.edges = MathBlockCollectionPrimitives.CopyEnumerable(edges);
        for (var index = 0; index < this.edges.Length; index++)
            this.edges[index] = this.edges[index].Validate(vertexCount);
    }

    public int VertexCount { get; }
    public int Count => edges.Length;
    public MathBlockGraphEdge this[int index] => edges[index];
    internal ReadOnlySpan<MathBlockGraphEdge> Span => edges;
    public MathBlockGraphEdge[] ToArray() => MathBlockCollectionPrimitives.Copy(edges);
    public IEnumerator<MathBlockGraphEdge> GetEnumerator() => ((IEnumerable<MathBlockGraphEdge>)edges).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => edges.GetEnumerator();
}

public readonly record struct MathBlockRun(int Start, int Length, double Value)
{
    public MathBlockRun Validate()
    {
        if (Start < 0 || Length <= 0 || !Math.IsFinite(Value))
            throw new InvalidDataException("A run has invalid state.");
        return this;
    }
}

public sealed class MathBlockRunSet : IReadOnlyList<MathBlockRun>
{
    private readonly MathBlockRun[] runs;

    public MathBlockRunSet(IEnumerable<MathBlockRun> runs)
    {
        ArgumentNullException.ThrowIfNull(runs);
        this.runs = MathBlockCollectionPrimitives.CopyEnumerable(runs);
        for (var index = 0; index < this.runs.Length; index++)
            this.runs[index] = this.runs[index].Validate();
    }

    public int Count => runs.Length;
    public MathBlockRun this[int index] => runs[index];
    public MathBlockRun[] ToArray() => MathBlockCollectionPrimitives.Copy(runs);
    public IEnumerator<MathBlockRun> GetEnumerator() => ((IEnumerable<MathBlockRun>)runs).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => runs.GetEnumerator();
}

internal static class MathBlockDataValidation
{
    public static bool IsFinite(Complex value) =>
        Math.IsFinite(value.Real) && Math.IsFinite(value.Imaginary);
}
