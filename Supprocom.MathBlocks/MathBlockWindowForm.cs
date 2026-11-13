namespace Supprocom.MathBlocks;

// One generic lift turns a series operation into its trailing-window form. Row t for t >= width - 1 is the
// source operation's own CoreCLR evaluation on input rows t - width + 1 .. t of every series input, with scalar
// parameters passed through unchanged. Warm-up rows and rows where the source result is invalid hold the fill
// value; the validity sibling marks exactly the rows that were computed.
// A form with a kernel computes its rows with the kernel instead of evaluating the source on each window. The
// type, length, width and fill rules stay those of the lift. For the window.* forms the kernel gives the same bits
// as the direct lift; the window-accurate.* forms use the source only for their types.
internal sealed class MathBlockWindowForm
{
    private readonly MathBlockOperation source;
    private readonly MathBlockWindowLift lift;
    private readonly bool[] series;
    private readonly MathBlockWindowKernel? kernel;
    private readonly bool totalVariation;

    internal MathBlockWindowForm(
        MathBlockOperation source,
        MathBlockWindowLift lift,
        bool[] series,
        MathBlockWindowKernel? kernel = null)
        : this(source, lift, series, kernel, allowDirectRows: true)
    {
    }

    private MathBlockWindowForm(
        MathBlockOperation source,
        MathBlockWindowLift lift,
        bool[] series,
        MathBlockWindowKernel? kernel,
        bool allowDirectRows)
    {
        if (series.Length != source.Arity)
            throw new ArgumentException("The window series map must cover every source input.", nameof(series));
        this.source = source;
        this.lift = lift;
        this.series = series;
        this.kernel = kernel;
        totalVariation = allowDirectRows && lift == MathBlockWindowLift.Scalar && series.Length == 1 && series[0] &&
            string.Equals(source.Identity, PathMathBlocks.PathTotalVariationV1Block.Identity, StringComparison.Ordinal);
        FormTypeResolver = ResolveFormType;
        ValidityTypeResolver = ResolveValidityType;
    }

    internal MathBlockOperation Source => source;

    internal MathBlockWindowKernel? Kernel => kernel;

    // The same form evaluated by the direct lift, kept as the reference for the kernels.
    internal MathBlockWindowForm WithoutKernel() => new(source, lift, series, null, allowDirectRows: false);

    internal int SourceArity => source.Arity;

    internal MathBlockTypeResolver FormTypeResolver { get; }

    internal MathBlockTypeResolver ValidityTypeResolver { get; }

    internal int FormArity => source.Arity + 2;

    // The signature of the form or of its validity sibling: the lifted operation's signature row embedded in a lift row.
    internal MathBlockTypeSignature? CreateSignature(string identity, bool validity)
    {
        if (source.TypeSignature is not { RuleKind: MathBlockTypeRuleKind.Composed } inner)
            return null;
        var seriesKinds = MathBlockTypeOperand.KindBit(MathBlockValueKind.Vector) |
            MathBlockTypeOperand.KindBit(MathBlockValueKind.BooleanVector);
        var operands = new List<MathBlockTypeOperand>(inner.Operands.Count + 2);
        var seriesMask = 0;
        for (var index = 0; index < inner.Operands.Count; index++)
        {
            var operand = inner.Operands[index];
            if (series[index])
            {
                seriesMask |= 1 << index;
                operand = operand with { AcceptedKindMask = operand.AcceptedKindMask & seriesKinds };
            }
            operands.Add(operand with { IsConstant = false });
        }
        operands.Add(new MathBlockTypeOperand(
            MathBlockTypeOperand.KindBit(MathBlockValueKind.Scalar), MathBlockTypeOperand.DimensionlessUnit, true));
        if (!validity)
            operands.Add(new MathBlockTypeOperand(MathBlockTypeOperand.KindBit(MathBlockValueKind.Scalar), MathBlockTypeOperand.AnyUnit, false));
        return new MathBlockTypeSignature(
            identity,
            MathBlockTypeRuleKind.WindowForm,
            [validity ? 1 : 0, lift == MathBlockWindowLift.LastRow ? 1 : 0, seriesMask, .. inner.ToRow()],
            operands);
    }

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

    internal MathBlockValue EvaluateForm(IReadOnlyList<MathBlockValue> inputs) => EvaluateForm(inputs, null, null);

    internal MathBlockValue EvaluateValidity(IReadOnlyList<MathBlockValue> inputs) => EvaluateValidity(inputs, null);

    // With a capture, the same pass also computes the validity rows and leaves them in the capture.
    internal MathBlockValue EvaluateForm(
        IReadOnlyList<MathBlockValue> inputs,
        MathBlockWindowPreparation? preparation,
        MathBlockWindowValidityCapture? capture)
    {
        var type = FormTypeResolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
        if (!TryResolveExtent(inputs, type, out var count, out var width, out var invalid))
            return invalid;
        var values = new double[count];
        var valid = capture is null ? null : new bool[count];
        Run(inputs, count, width, inputs[source.Arity + 1].AsScalar(), values, valid, preparation);
        if (capture is not null)
            capture.Valid = valid;
        return MathBlockValue.Vector(values, type.Unit, true);
    }

    internal MathBlockValue EvaluateValidity(
        IReadOnlyList<MathBlockValue> inputs,
        MathBlockWindowPreparation? preparation)
    {
        var type = ValidityTypeResolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
        if (!TryResolveExtent(inputs, type, out var count, out var width, out var invalid))
            return invalid;
        var valid = new bool[count];
        Run(inputs, count, width, 0d, null, valid, preparation);
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
        bool[]? valid,
        MathBlockWindowPreparation? preparation)
    {
        if (kernel is not null)
        {
            var prepared = preparation is null ? kernel.Prepare(inputs) : preparation.Get(kernel, inputs);
            kernel.Run(prepared, inputs, count, width, fill, values, valid);
            return;
        }

        if (totalVariation && TryRunTotalVariation(inputs, count, width, fill, values, valid))
            return;

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

    // Rows of window.path.total-variation without evaluating the source on each window.
    //
    // Equivalence argument. For window end t, the direct lift evaluates path.total-variation@1 on a vector value
    // holding series[t - width + 1 .. t]. That evaluation is, in order:
    //   1. outputType = SameUnitScalar(Vector(unit, width)): the same for every window, since the unit and the width
    //      are fixed. It is resolved once here from the same type, so a resolver exception is the same exception.
    //   2. The input is valid, so there is no invalid-input result.
    //   3. width >= 1, so the path is not empty and the evaluator returns
    //      MathBlockValue.Scalar(MathBlockPath.TotalVariation(window), outputType.Unit). TotalVariation is
    //      result = 0; result += Math.Abs(window[i] - window[i - 1]) for i = 1 .. width - 1, in that order. No
    //      exception can come out of it (it is double arithmetic). The loop below runs those very operations on the
    //      same doubles in the same order for each window, with no running sum or reuse between windows, so every
    //      sum has the same rounding. The scalar value is valid exactly when the sum is finite, and then holds the sum.
    //   4. outputType.Accepts(result.Type) is checked on a result of type Scalar(outputType.Unit), valid or not,
    //      so it has one outcome for the run. It is evaluated once; if it would throw, this method returns false and
    //      the direct lift throws on its first window, as before.
    //   5. The final type normalisation keeps IsValid, and the lift reads only IsValid and the scalar.
    // Rows before the first full window keep fill and an unset validity flag, as in the direct lift. The valid
    // array is zero-initialised by its callers, as for the direct lift.
    private bool TryRunTotalVariation(
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        int width,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var input = inputs[0];
        if (input.Type.Kind != MathBlockValueKind.Vector)
            return false;
        var outputType = source.ResolveOutputType([MathBlockType.Vector(input.Type.Unit, width)]);
        if (!outputType.Accepts(MathBlockType.Scalar(outputType.Unit)))
            return false;

        var path = input.AsVector().Span;
        if (values is not null)
            for (var row = 0; row < width - 1; row++)
                values[row] = fill;
        for (var end = width - 1; end < count; end++)
        {
            var start = end - width + 1;
            var sum = 0d;
            for (var index = start + 1; index <= end; index++)
                sum += Math.Abs(path[index] - path[index - 1]);
            var computed = Math.IsFinite(sum);
            if (valid is not null)
                valid[end] = computed;
            if (values is not null)
                values[end] = computed ? sum : fill;
        }
        return true;
    }
}
