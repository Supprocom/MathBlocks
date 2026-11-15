namespace Supprocom.MathBlocks;

/// <summary>Describes one operand of a non-allocating CoreCLR evaluation as a view over caller-owned memory.</summary>
/// <remarks>
/// The evaluation reads the memory during the call only, so the caller keeps ownership and may reuse it afterwards.
/// An argument stands for the <see cref="MathBlockValue"/> that holds the same numbers: a vector with a nonfinite
/// element or a nonfinite scalar is an invalid input, and the evaluation of it is invalid, as it is for the invalid
/// <see cref="MathBlockValue"/>. The default value is not an argument; create one with a factory.
/// </remarks>
public readonly ref struct MathBlockSpanArgument
{
    private readonly ReadOnlySpan<double> values;
    private readonly ReadOnlySpan<bool> flags;
    private readonly double scalar;
    private readonly bool verified;

    private MathBlockSpanArgument(
        MathBlockValueKind kind,
        MathBlockUnit unit,
        double scalar,
        ReadOnlySpan<double> values,
        ReadOnlySpan<bool> flags,
        bool verified)
    {
        Kind = kind;
        Unit = unit;
        this.scalar = scalar;
        this.values = values;
        this.flags = flags;
        this.verified = verified;
    }

    /// <summary>Gets the kind of the value the argument stands for; zero for the default value, which is not an argument.</summary>
    public MathBlockValueKind Kind { get; }

    /// <summary>Gets the unit of the value the argument stands for.</summary>
    public MathBlockUnit Unit { get; }

    /// <summary>Creates a scalar argument with the specified unit.</summary>
    public static MathBlockSpanArgument Scalar(double value, MathBlockUnit unit = default) =>
        new(MathBlockValueKind.Scalar, unit, value, default, default, false);

    /// <summary>Creates a vector argument over the specified elements with the specified unit.</summary>
    public static MathBlockSpanArgument Vector(ReadOnlySpan<double> values, MathBlockUnit unit = default) =>
        new(MathBlockValueKind.Vector, unit, 0d, values, default, false);

    /// <summary>Creates a Boolean-vector argument over the specified elements.</summary>
    public static MathBlockSpanArgument BooleanVector(ReadOnlySpan<bool> values) =>
        new(MathBlockValueKind.BooleanVector, MathBlockUnit.Dimensionless, 0d, default, values, false);

    internal ReadOnlySpan<double> Values => values;

    internal ReadOnlySpan<bool> Flags => flags;

    internal double ScalarValue => scalar;

    // The view of an input value that is valid and of a kind the span kernels read, whose data is finite already. Any
    // other value gives the default view, and every kernel declines it.
    internal static MathBlockSpanArgument FromValue(MathBlockValue value)
    {
        if (!value.IsValid)
            return default;
        return value.Type.Kind switch
        {
            MathBlockValueKind.Scalar => new(MathBlockValueKind.Scalar, value.Type.Unit, value.AsScalar(), default, default, true),
            MathBlockValueKind.Vector => new(MathBlockValueKind.Vector, value.Type.Unit, 0d, value.AsVector().Span, default, true),
            MathBlockValueKind.BooleanVector => new(MathBlockValueKind.BooleanVector, MathBlockUnit.Dimensionless, 0d, default, value.AsBooleanVector().Span, true),
            _ => default
        };
    }

    // True when the data is finite: a view of a valid value is, and any other view is tested.
    internal bool HoldsFiniteData() =>
        verified || Kind switch
        {
            MathBlockValueKind.Scalar => Math.IsFinite(scalar),
            MathBlockValueKind.Vector => MathBlockSimd.AllFinite(values),
            _ => true
        };

    // The value that holds the same numbers, which is invalid where the data is not finite.
    internal MathBlockValue ToValue() => Kind switch
    {
        MathBlockValueKind.Scalar => MathBlockValue.Scalar(scalar, Unit),
        MathBlockValueKind.Vector => MathBlockValue.Vector(values.ToArray(), Unit, takeOwnership: true),
        MathBlockValueKind.BooleanVector => MathBlockValue.BooleanVector(flags.ToArray(), takeOwnership: true),
        _ => throw new InvalidOperationException("The span argument was not created by one of its factories.")
    };
}
