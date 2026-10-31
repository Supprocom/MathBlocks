namespace Supprocom.MathBlocks;

// One generic lift turns a series operation into its trailing-window form. Row t for t >= width - 1 is the
// source operation's own CoreCLR evaluation on input rows t - width + 1 .. t of every series input, with scalar
// parameters passed through unchanged. Warm-up rows and rows where the source result is invalid hold the fill
// value; the validity sibling marks exactly the rows that were computed.
// A form with a kernel computes its rows with the kernel instead of evaluating the source on each window. The
// type, length, width and fill rules stay those of the lift. For the window.* forms the kernel gives the same bits
// as the direct lift; the window-prefix.* forms use the source only for their types.
internal sealed class MathBlockWindowForm
{
    private readonly MathBlockOperation source;
    private readonly MathBlockWindowLift lift;
    private readonly bool[] series;
    private readonly MathBlockWindowKernel? kernel;

    internal MathBlockWindowForm(
        MathBlockOperation source,
        MathBlockWindowLift lift,
        bool[] series,
        MathBlockWindowKernel? kernel = null)
    {
        if (series.Length != source.Arity)
            throw new ArgumentException("The window series map must cover every source input.", nameof(series));
        this.source = source;
        this.lift = lift;
        this.series = series;
        this.kernel = kernel;
        FormTypeResolver = ResolveFormType;
        ValidityTypeResolver = ResolveValidityType;
    }

    internal MathBlockOperation Source => source;

    internal MathBlockWindowKernel? Kernel => kernel;

    // The same form evaluated by the direct lift, kept as the reference for the kernels.
    internal MathBlockWindowForm WithoutKernel() => new(source, lift, series);

    internal int SourceArity => source.Arity;

    internal MathBlockTypeResolver FormTypeResolver { get; }

    internal MathBlockTypeResolver ValidityTypeResolver { get; }

    internal int FormArity => source.Arity + 2;

    internal int ValidityArity => source.Arity + 1;

    private MathBlockType ResolveFormType(IReadOnlyList<MathBlockType> types)
    {
        var sourceType = ResolveSourceType(types, out var rows);
        RequireWidthType(types[source.Arity]);
        var fill = types[source.Arity + 1];
        MathBlockTypeRules.RequireKind(fill, MathBlockValueKind.Scalar);
        if (fill.Unit != sourceType.Unit)
            throw new InvalidOperationException("The fill unit must equal the window result unit.");
        return MathBlockType.Vector(sourceType.Unit, rows);
    }

    private MathBlockType ResolveValidityType(IReadOnlyList<MathBlockType> types)
    {
        _ = ResolveSourceType(types, out var rows);
        RequireWidthType(types[source.Arity]);
        return MathBlockType.BooleanVector(rows);
    }

    internal MathBlockValue EvaluateForm(IReadOnlyList<MathBlockValue> inputs)
    {
        var type = FormTypeResolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
        if (!TryResolveExtent(inputs, type, out var count, out var width, out var invalid))
            return invalid;
        var values = new double[count];
        Run(inputs, count, width, inputs[source.Arity + 1].AsScalar(), values, null);
        return MathBlockValue.Vector(values, type.Unit, true);
    }

    internal MathBlockValue EvaluateValidity(IReadOnlyList<MathBlockValue> inputs)
    {
        var type = ValidityTypeResolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
        if (!TryResolveExtent(inputs, type, out var count, out var width, out var invalid))
            return invalid;
        var valid = new bool[count];
        Run(inputs, count, width, 0d, null, valid);
        return MathBlockValue.BooleanVector(valid, true);
    }

    // The unit of one window's result for the given series and parameter types.
    internal MathBlockUnit ResolveResultUnit(IReadOnlyList<MathBlockType> sourceTypes) =>
        ResolveSourceType(sourceTypes, out _).Unit;

    // The source resolver sees shapeless series types, so equal-length checks happen per evaluation and unequal
    // lengths give an invalid result rather than a type error.
    private MathBlockType ResolveSourceType(IReadOnlyList<MathBlockType> types, out int rows)
    {
        var sourceTypes = new MathBlockType[source.Arity];
        rows = 0;
        var consistent = true;
        for (var index = 0; index < source.Arity; index++)
        {
            var type = types[index];
            if (!series[index])
            {
                sourceTypes[index] = type;
                continue;
            }
            if (type.Kind is not (MathBlockValueKind.Vector or MathBlockValueKind.BooleanVector))
                throw new InvalidOperationException($"Expected a series input, but found '{type.Kind}'.");
            if (type.Rows > 0)
            {
                if (rows == 0)
                    rows = type.Rows;
                else if (rows != type.Rows)
                    consistent = false;
            }
            sourceTypes[index] = new MathBlockType(type.Kind, type.Unit);
        }
        if (!consistent)
            rows = 0;
        var output = source.ResolveOutputType(sourceTypes);
        MathBlockTypeRules.RequireKind(
            output,
            lift == MathBlockWindowLift.Scalar ? MathBlockValueKind.Scalar : MathBlockValueKind.Vector);
        return output;
    }

    private static void RequireWidthType(MathBlockType type)
    {
        MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(type);
    }

    private bool TryResolveExtent(
        IReadOnlyList<MathBlockValue> inputs,
        MathBlockType type,
        out int count,
        out int width,
        out MathBlockValue invalid)
    {
        count = -1;
        for (var index = 0; index < source.Arity; index++)
        {
            if (!series[index])
                continue;
            var length = inputs[index].Type.Kind == MathBlockValueKind.Vector
                ? inputs[index].AsVector().Count
                : inputs[index].AsBooleanVector().Count;
            if (count < 0)
            {
                count = length;
            }
            else if (count != length)
            {
                width = 0;
                invalid = MathBlockValue.Invalid(type, "The window series lengths differ.");
                return false;
            }
        }
        width = VectorMathBlocks.RequirePositiveInteger(inputs[source.Arity].AsScalar());
        if (width > count)
        {
            invalid = MathBlockValue.Invalid(type, "The width is outside the sequence domain.");
            return false;
        }
        invalid = default;
        return true;
    }

    // Each series input gets one reusable window buffer wrapped once in a valid value. Only this call sees the
    // buffers; the source evaluator reads them and returns a fresh result, so no window value escapes. All state
    // is local, so concurrent evaluations are independent.
    private void Run(
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        int width,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        if (kernel is not null)
        {
            kernel.Run(kernel.Prepare(inputs), inputs, count, width, fill, values, valid);
            return;
        }

        var windowInputs = new MathBlockValue[source.Arity];
        var vectors = new MathBlockVector?[source.Arity];
        var booleanVectors = new MathBlockBooleanVector?[source.Arity];
        var vectorBuffers = new double[]?[source.Arity];
        var booleanBuffers = new bool[]?[source.Arity];
        for (var index = 0; index < source.Arity; index++)
        {
            if (!series[index])
            {
                windowInputs[index] = inputs[index];
            }
            else if (inputs[index].Type.Kind == MathBlockValueKind.Vector)
            {
                vectors[index] = inputs[index].AsVector();
                var buffer = new double[width];
                vectorBuffers[index] = buffer;
                windowInputs[index] = MathBlockValue.Vector(buffer, inputs[index].Type.Unit, true);
            }
            else
            {
                booleanVectors[index] = inputs[index].AsBooleanVector();
                var buffer = new bool[width];
                booleanBuffers[index] = buffer;
                windowInputs[index] = MathBlockValue.BooleanVector(buffer, true);
            }
        }

        if (values is not null)
            for (var row = 0; row < width - 1; row++)
                values[row] = fill;
        for (var end = width - 1; end < count; end++)
        {
            var start = end - width + 1;
            for (var index = 0; index < source.Arity; index++)
            {
                if (vectors[index] is { } vector)
                    vector.Span.Slice(start, width).CopyTo(vectorBuffers[index]);
                else if (booleanVectors[index] is { } booleanVector)
                    booleanVector.Span.Slice(start, width).CopyTo(booleanBuffers[index]);
            }
            var result = source.Evaluate(windowInputs);
            if (valid is not null)
                valid[end] = result.IsValid;
            if (values is not null)
            {
                values[end] = !result.IsValid
                    ? fill
                    : lift == MathBlockWindowLift.Scalar
                        ? result.AsScalar()
                        : result.AsVector()[width - 1];
            }
        }
    }
}
