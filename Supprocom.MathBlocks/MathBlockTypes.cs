using System.Globalization;

namespace Supprocom.MathBlocks;

public readonly record struct MathRational
{
    private readonly int denominator;

    public MathRational(int numerator, int denominator = 1)
    {
        if (denominator == 0)
            throw new DivideByZeroException("A rational denominator cannot be zero.");
        var sign = denominator < 0 ? -1L : 1L;
        var normalizedNumerator = (long)numerator * sign;
        var normalizedDenominator = (long)denominator * sign;
        var divisor = GreatestCommonDivisor(Math.Abs(normalizedNumerator), normalizedDenominator);
        normalizedNumerator /= divisor;
        normalizedDenominator /= divisor;
        if (normalizedNumerator is < int.MinValue or > int.MaxValue ||
            normalizedDenominator is < 1 or > int.MaxValue)
        {
            throw new OverflowException("The normalized rational value is outside the supported range.");
        }
        Numerator = (int)normalizedNumerator;
        this.denominator = normalizedNumerator == 0 ? 0 : (int)normalizedDenominator;
    }

    public int Numerator { get; }
    public int Denominator => denominator == 0 ? 1 : denominator;
    public bool IsZero => Numerator == 0;

    public static MathRational Zero => new(0);
    public static MathRational One => new(1);

    public static MathRational operator +(MathRational left, MathRational right) =>
        CreateChecked(
            (long)left.Numerator * right.Denominator + (long)right.Numerator * left.Denominator,
            (long)left.Denominator * right.Denominator);

    public static MathRational operator -(MathRational left, MathRational right) =>
        CreateChecked(
            (long)left.Numerator * right.Denominator - (long)right.Numerator * left.Denominator,
            (long)left.Denominator * right.Denominator);

    public static MathRational operator *(MathRational left, MathRational right) =>
        CreateChecked(
            (long)left.Numerator * right.Numerator,
            (long)left.Denominator * right.Denominator);

    public override string ToString() => Denominator == 1
        ? Numerator.ToString(CultureInfo.InvariantCulture)
        : $"{Numerator.ToString(CultureInfo.InvariantCulture)}/{Denominator.ToString(CultureInfo.InvariantCulture)}";

    private static MathRational CreateChecked(long numerator, long denominator)
    {
        var divisor = GreatestCommonDivisor(Math.Abs(numerator), Math.Abs(denominator));
        numerator /= divisor;
        denominator /= divisor;
        if (denominator < 0)
        {
            numerator = -numerator;
            denominator = -denominator;
        }
        if (numerator is < int.MinValue or > int.MaxValue || denominator is < 1 or > int.MaxValue)
            throw new OverflowException("The rational operation exceeded the supported range.");
        return new MathRational((int)numerator, (int)denominator);
    }

    private static long GreatestCommonDivisor(long left, long right)
    {
        if (left == 0)
            return right == 0 ? 1 : right;
        while (right != 0)
            (left, right) = (right, left % right);
        return left;
    }
}

public readonly record struct MathBlockUnit(
    MathRational Dimension0,
    MathRational Dimension1,
    MathRational Dimension2,
    MathRational Dimension3)
{
    public static MathBlockUnit Dimensionless => default;
    public static MathBlockUnit Basis0 => new(MathRational.One, default, default, default);
    public static MathBlockUnit Basis1 => new(default, MathRational.One, default, default);
    public static MathBlockUnit Basis2 => new(default, default, MathRational.One, default);
    public static MathBlockUnit Basis3 => new(default, default, default, MathRational.One);

    public bool IsDimensionless =>
        Dimension0.IsZero && Dimension1.IsZero && Dimension2.IsZero && Dimension3.IsZero;

    public MathBlockUnit Multiply(MathBlockUnit other) => new(
        Dimension0 + other.Dimension0,
        Dimension1 + other.Dimension1,
        Dimension2 + other.Dimension2,
        Dimension3 + other.Dimension3);

    public MathBlockUnit Divide(MathBlockUnit other) => new(
        Dimension0 - other.Dimension0,
        Dimension1 - other.Dimension1,
        Dimension2 - other.Dimension2,
        Dimension3 - other.Dimension3);

    public MathBlockUnit Pow(MathRational exponent) => new(
        Dimension0 * exponent,
        Dimension1 * exponent,
        Dimension2 * exponent,
        Dimension3 * exponent);

    public override string ToString() =>
        $"d0^{Dimension0}|d1^{Dimension1}|d2^{Dimension2}|d3^{Dimension3}";
}

public enum MathBlockValueKind
{
    Scalar = 1,
    Boolean = 2,
    Complex = 3,
    Vector = 4,
    Matrix = 5,
    ComplexVector = 6,
    ComplexMatrix = 7,
    PointSet = 8,
    Graph = 9,
    RunSet = 10,
    BooleanVector = 11
}

public readonly record struct MathBlockType(
    MathBlockValueKind Kind,
    MathBlockUnit Unit,
    int Rows = 0,
    int Columns = 0)
{
    public static MathBlockType Scalar(MathBlockUnit unit = default) =>
        new(MathBlockValueKind.Scalar, unit);

    public static MathBlockType Boolean =>
        new(MathBlockValueKind.Boolean, MathBlockUnit.Dimensionless);

    public static MathBlockType Complex(MathBlockUnit unit = default) =>
        new(MathBlockValueKind.Complex, unit);

    public static MathBlockType Vector(MathBlockUnit unit = default, int length = 0) =>
        new(MathBlockValueKind.Vector, unit, length);

    public static MathBlockType Matrix(MathBlockUnit unit = default, int rows = 0, int columns = 0) =>
        new(MathBlockValueKind.Matrix, unit, rows, columns);

    public static MathBlockType ComplexVector(MathBlockUnit unit = default, int length = 0) =>
        new(MathBlockValueKind.ComplexVector, unit, length);

    public static MathBlockType ComplexMatrix(MathBlockUnit unit = default, int rows = 0, int columns = 0) =>
        new(MathBlockValueKind.ComplexMatrix, unit, rows, columns);

    public static MathBlockType PointSet(MathBlockUnit unit = default, int count = 0) =>
        new(MathBlockValueKind.PointSet, unit, count);

    public static MathBlockType Graph(MathBlockUnit unit = default, int vertexCount = 0) =>
        new(MathBlockValueKind.Graph, unit, vertexCount);

    public static MathBlockType RunSet(MathBlockUnit unit = default, int count = 0) =>
        new(MathBlockValueKind.RunSet, unit, count);

    public static MathBlockType BooleanVector(int length = 0) =>
        new(MathBlockValueKind.BooleanVector, MathBlockUnit.Dimensionless, length);

    public bool Accepts(MathBlockType actual) =>
        Kind == actual.Kind &&
        Unit == actual.Unit &&
        (Rows == 0 || Rows == actual.Rows) &&
        (Columns == 0 || Columns == actual.Columns);

    public override string ToString() => $"{Kind}[{Rows},{Columns}]<{Unit}>";
}
