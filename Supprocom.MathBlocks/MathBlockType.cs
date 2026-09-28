using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

/// <summary>Describes the kind, unit, and optional shape of a MathBlocks value.</summary>
/// <param name="Kind">The kind value.</param>
/// <param name="Unit">The unit value.</param>
/// <param name="Rows">The rows value.</param>
/// <param name="Columns">The columns value.</param>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockType(
    MathBlockValueKind Kind,
    MathBlockUnit Unit,
    int Rows = 0,
    int Columns = 0)
{
    /// <summary>Creates a scalar type with the specified unit.</summary>
    public static MathBlockType Scalar(MathBlockUnit unit = default) =>
        new(MathBlockValueKind.Scalar, unit);

    /// <summary>Gets the dimensionless Boolean type.</summary>
    public static MathBlockType Boolean =>
        new(MathBlockValueKind.Boolean, MathBlockUnit.Dimensionless);

    /// <summary>Creates a complex scalar type with the specified unit.</summary>
    public static MathBlockType Complex(MathBlockUnit unit = default) =>
        new(MathBlockValueKind.Complex, unit);

    /// <summary>Creates a vector type with an optional fixed length.</summary>
    public static MathBlockType Vector(MathBlockUnit unit = default, int length = 0) =>
        new(MathBlockValueKind.Vector, unit, length);

    /// <summary>Creates a matrix type with optional fixed dimensions.</summary>
    public static MathBlockType Matrix(MathBlockUnit unit = default, int rows = 0, int columns = 0) =>
        new(MathBlockValueKind.Matrix, unit, rows, columns);

    /// <summary>Creates a complex-vector type with an optional fixed length.</summary>
    public static MathBlockType ComplexVector(MathBlockUnit unit = default, int length = 0) =>
        new(MathBlockValueKind.ComplexVector, unit, length);

    /// <summary>Creates a complex-matrix type with optional fixed dimensions.</summary>
    public static MathBlockType ComplexMatrix(MathBlockUnit unit = default, int rows = 0, int columns = 0) =>
        new(MathBlockValueKind.ComplexMatrix, unit, rows, columns);

    /// <summary>Creates a point-set type with an optional fixed count.</summary>
    public static MathBlockType PointSet(MathBlockUnit unit = default, int count = 0) =>
        new(MathBlockValueKind.PointSet, unit, count);

    /// <summary>Creates a graph type with an optional fixed vertex count.</summary>
    public static MathBlockType Graph(MathBlockUnit unit = default, int vertexCount = 0) =>
        new(MathBlockValueKind.Graph, unit, vertexCount);

    /// <summary>Creates a run-set type with an optional fixed count.</summary>
    public static MathBlockType RunSet(MathBlockUnit unit = default, int count = 0) =>
        new(MathBlockValueKind.RunSet, unit, count);

    /// <summary>Creates a Boolean-vector type with an optional fixed length.</summary>
    public static MathBlockType BooleanVector(int length = 0) =>
        new(MathBlockValueKind.BooleanVector, MathBlockUnit.Dimensionless, length);

    /// <summary>Tests whether an actual type satisfies this kind, unit, and shape.</summary>
    public bool Accepts(MathBlockType actual) =>
        Kind == actual.Kind &&
        Unit == actual.Unit &&
        (Rows == 0 || Rows == actual.Rows) &&
        (Columns == 0 || Columns == actual.Columns);

    /// <summary>Formats the kind, shape, and unit for diagnostics.</summary>
    public override string ToString() => $"{Kind}[{Rows},{Columns}]<{Unit}>";
}
