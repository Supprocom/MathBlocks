
namespace Supprocom.MathBlocks;

public readonly struct MathBlockValue
{
    private readonly double scalar;
    private readonly bool boolean;
    private readonly Complex complex;
    private readonly object? reference;

    private MathBlockValue(
        MathBlockType type,
        bool isValid,
        string? invalidReason,
        double scalar = default,
        bool boolean = default,
        Complex complex = default,
        object? reference = null)
    {
        Type = type;
        IsValid = isValid;
        InvalidReason = invalidReason;
        this.scalar = scalar;
        this.boolean = boolean;
        this.complex = complex;
        this.reference = reference;
    }

    public MathBlockType Type { get; }
    public bool IsValid { get; }
    public string? InvalidReason { get; }

    public static MathBlockValue Invalid(MathBlockType type, string reason) =>
        new(type, false, RequireReason(reason));

    public static MathBlockValue Scalar(double value, MathBlockUnit unit = default) =>
        Math.IsFinite(value)
            ? new(MathBlockType.Scalar(unit), true, null, scalar: value)
            : Invalid(MathBlockType.Scalar(unit), "The scalar result is not finite.");

    public static MathBlockValue Boolean(bool value) =>
        new(MathBlockType.Boolean, true, null, boolean: value);

    public static MathBlockValue Complex(Complex value, MathBlockUnit unit = default) =>
        MathBlockDataValidation.IsFinite(value)
            ? new(MathBlockType.Complex(unit), true, null, complex: value)
            : Invalid(MathBlockType.Complex(unit), "The complex result is not finite.");

    public static MathBlockValue Vector(IEnumerable<double> values, MathBlockUnit unit = default)
    {
        var vector = new MathBlockVector(values);
        return new MathBlockValue(MathBlockType.Vector(unit, vector.Count), true, null, reference: vector);
    }

    internal static MathBlockValue Vector(double[] values, MathBlockUnit unit, bool takeOwnership) =>
        MathBlockCollectionPrimitives.All(values, Math.IsFinite)
            ? new(MathBlockType.Vector(unit, values.Length), true, null,
                reference: new MathBlockVector(values, takeOwnership))
            : Invalid(MathBlockType.Vector(unit, values.Length), "The vector result contains a nonfinite value.");

    public static MathBlockValue Matrix(MathBlockMatrix value, MathBlockUnit unit = default)
    {
        ArgumentNullException.ThrowIfNull(value);
        foreach (var item in value.Span)
            if (!Math.IsFinite(item))
                return Invalid(MathBlockType.Matrix(unit, value.Rows, value.Columns),
                    "The matrix result contains a nonfinite value.");
        return new MathBlockValue(
            MathBlockType.Matrix(unit, value.Rows, value.Columns), true, null, reference: value);
    }

    public static MathBlockValue ComplexVector(IEnumerable<Complex> values, MathBlockUnit unit = default)
    {
        var vector = new MathBlockComplexVector(values);
        return new MathBlockValue(MathBlockType.ComplexVector(unit, vector.Count), true, null, reference: vector);
    }

    internal static MathBlockValue ComplexVector(Complex[] values, MathBlockUnit unit, bool takeOwnership) =>
        MathBlockCollectionPrimitives.All(values, MathBlockDataValidation.IsFinite)
            ? new(MathBlockType.ComplexVector(unit, values.Length), true, null,
                reference: new MathBlockComplexVector(values, takeOwnership))
            : Invalid(MathBlockType.ComplexVector(unit, values.Length), "The complex vector result contains a nonfinite value.");

    public static MathBlockValue BooleanVector(IEnumerable<bool> values)
    {
        var vector = new MathBlockBooleanVector(values);
        return new MathBlockValue(MathBlockType.BooleanVector(vector.Count), true, null, reference: vector);
    }

    internal static MathBlockValue BooleanVector(bool[] values, bool takeOwnership) =>
        new(MathBlockType.BooleanVector(values.Length), true, null,
            reference: new MathBlockBooleanVector(values, takeOwnership));

    public static MathBlockValue ComplexMatrix(MathBlockComplexMatrix value, MathBlockUnit unit = default)
    {
        ArgumentNullException.ThrowIfNull(value);
        foreach (var item in value.Span)
            if (!MathBlockDataValidation.IsFinite(item))
                return Invalid(MathBlockType.ComplexMatrix(unit, value.Rows, value.Columns),
                    "The complex matrix result contains a nonfinite value.");
        return new MathBlockValue(
            MathBlockType.ComplexMatrix(unit, value.Rows, value.Columns), true, null, reference: value);
    }

    public static MathBlockValue PointSet(MathBlockPointSet value, MathBlockUnit unit = default)
    {
        ArgumentNullException.ThrowIfNull(value);
        return new MathBlockValue(MathBlockType.PointSet(unit, value.Count), true, null, reference: value);
    }

    public static MathBlockValue Graph(MathBlockGraph value, MathBlockUnit unit = default)
    {
        ArgumentNullException.ThrowIfNull(value);
        return new MathBlockValue(MathBlockType.Graph(unit, value.VertexCount), true, null, reference: value);
    }

    public static MathBlockValue RunSet(MathBlockRunSet value, MathBlockUnit unit = default)
    {
        ArgumentNullException.ThrowIfNull(value);
        return new MathBlockValue(MathBlockType.RunSet(unit, value.Count), true, null, reference: value);
    }

    public double AsScalar() => Require<double>(MathBlockValueKind.Scalar, scalar);
    public bool AsBoolean() => Require<bool>(MathBlockValueKind.Boolean, boolean);
    public Complex AsComplex() => Require<Complex>(MathBlockValueKind.Complex, complex);
    public MathBlockVector AsVector() => RequireReference<MathBlockVector>(MathBlockValueKind.Vector);
    public MathBlockMatrix AsMatrix() => RequireReference<MathBlockMatrix>(MathBlockValueKind.Matrix);
    public MathBlockComplexVector AsComplexVector() => RequireReference<MathBlockComplexVector>(MathBlockValueKind.ComplexVector);
    public MathBlockBooleanVector AsBooleanVector() => RequireReference<MathBlockBooleanVector>(MathBlockValueKind.BooleanVector);
    public MathBlockComplexMatrix AsComplexMatrix() => RequireReference<MathBlockComplexMatrix>(MathBlockValueKind.ComplexMatrix);
    public MathBlockPointSet AsPointSet() => RequireReference<MathBlockPointSet>(MathBlockValueKind.PointSet);
    public MathBlockGraph AsGraph() => RequireReference<MathBlockGraph>(MathBlockValueKind.Graph);
    public MathBlockRunSet AsRunSet() => RequireReference<MathBlockRunSet>(MathBlockValueKind.RunSet);

    public bool ApproximatelyEquals(MathBlockValue other, double tolerance = 1e-12)
    {
        if (Type != other.Type || IsValid != other.IsValid)
            return false;
        if (!IsValid)
            return true;
        return Type.Kind switch
        {
            MathBlockValueKind.Scalar => Near(scalar, other.scalar, tolerance),
            MathBlockValueKind.Boolean => boolean == other.boolean,
            MathBlockValueKind.Complex => Near(complex.Real, other.complex.Real, tolerance) &&
                                          Near(complex.Imaginary, other.complex.Imaginary, tolerance),
            MathBlockValueKind.Vector => SequenceNear(AsVector(), other.AsVector(), tolerance),
            MathBlockValueKind.Matrix => MatrixNear(AsMatrix(), other.AsMatrix(), tolerance),
            MathBlockValueKind.ComplexVector => ComplexSequenceNear(AsComplexVector(), other.AsComplexVector(), tolerance),
            MathBlockValueKind.ComplexMatrix => ComplexMatrixNear(AsComplexMatrix(), other.AsComplexMatrix(), tolerance),
            MathBlockValueKind.PointSet => PointSetNear(AsPointSet(), other.AsPointSet(), tolerance),
            MathBlockValueKind.Graph => GraphNear(AsGraph(), other.AsGraph(), tolerance),
            MathBlockValueKind.RunSet => RunSetNear(AsRunSet(), other.AsRunSet(), tolerance),
            MathBlockValueKind.BooleanVector => BooleanSequenceEqual(AsBooleanVector(), other.AsBooleanVector()),
            _ => false
        };
    }

    private T Require<T>(MathBlockValueKind kind, T value)
    {
        RequireValid(kind);
        return value;
    }

    private T RequireReference<T>(MathBlockValueKind kind) where T : class
    {
        RequireValid(kind);
        return reference as T
            ?? throw new InvalidOperationException("The MathBlock value has no compatible reference value.");
    }

    private void RequireValid(MathBlockValueKind kind)
    {
        if (!IsValid)
            throw new InvalidOperationException($"The MathBlock value is invalid: {InvalidReason}");
        if (Type.Kind != kind)
            throw new InvalidOperationException($"Expected MathBlock kind '{kind}', but found '{Type.Kind}'.");
    }

    private static string RequireReason(string reason) =>
        string.IsNullOrWhiteSpace(reason)
            ? throw new ArgumentException("An invalid value reason is required.", nameof(reason))
            : reason.Trim();

    private static bool Near(double left, double right, double tolerance) =>
        Math.Abs(left - right) <= tolerance * Math.Max(1d, Math.Max(Math.Abs(left), Math.Abs(right)));

    private static bool SequenceNear(IReadOnlyList<double> left, IReadOnlyList<double> right, double tolerance)
    {
        if (left.Count != right.Count)
            return false;
        for (var index = 0; index < left.Count; index++)
            if (!Near(left[index], right[index], tolerance))
                return false;
        return true;
    }

    private static bool MatrixNear(MathBlockMatrix left, MathBlockMatrix right, double tolerance)
    {
        if (left.Rows != right.Rows || left.Columns != right.Columns)
            return false;
        for (var row = 0; row < left.Rows; row++)
            for (var column = 0; column < left.Columns; column++)
                if (!Near(left[row, column], right[row, column], tolerance))
                    return false;
        return true;
    }

    private static bool ComplexSequenceNear(
        IReadOnlyList<Complex> left,
        IReadOnlyList<Complex> right,
        double tolerance)
    {
        if (left.Count != right.Count)
            return false;
        for (var index = 0; index < left.Count; index++)
            if (!Near(left[index].Real, right[index].Real, tolerance) ||
                !Near(left[index].Imaginary, right[index].Imaginary, tolerance))
                return false;
        return true;
    }

    private static bool ComplexMatrixNear(
        MathBlockComplexMatrix left,
        MathBlockComplexMatrix right,
        double tolerance)
    {
        if (left.Rows != right.Rows || left.Columns != right.Columns)
            return false;
        for (var row = 0; row < left.Rows; row++)
            for (var column = 0; column < left.Columns; column++)
                if (!Near(left[row, column].Real, right[row, column].Real, tolerance) ||
                    !Near(left[row, column].Imaginary, right[row, column].Imaginary, tolerance))
                    return false;
        return true;
    }

    private static bool PointSetNear(MathBlockPointSet left, MathBlockPointSet right, double tolerance)
    {
        if (left.Count != right.Count)
            return false;
        for (var index = 0; index < left.Count; index++)
            if (!Near(left[index].X, right[index].X, tolerance) ||
                !Near(left[index].Y, right[index].Y, tolerance))
                return false;
        return true;
    }

    private static bool GraphNear(MathBlockGraph left, MathBlockGraph right, double tolerance)
    {
        if (left.VertexCount != right.VertexCount || left.Count != right.Count)
            return false;
        for (var index = 0; index < left.Count; index++)
            if (left[index].From != right[index].From || left[index].To != right[index].To ||
                !Near(left[index].Weight, right[index].Weight, tolerance))
                return false;
        return true;
    }

    private static bool RunSetNear(MathBlockRunSet left, MathBlockRunSet right, double tolerance)
    {
        if (left.Count != right.Count)
            return false;
        for (var index = 0; index < left.Count; index++)
            if (left[index].Start != right[index].Start || left[index].Length != right[index].Length ||
                !Near(left[index].Value, right[index].Value, tolerance))
                return false;
        return true;
    }

    private static bool BooleanSequenceEqual(IReadOnlyList<bool> left, IReadOnlyList<bool> right)
    {
        if (left.Count != right.Count)
            return false;
        for (var index = 0; index < left.Count; index++)
            if (left[index] != right[index])
                return false;
        return true;
    }
}
