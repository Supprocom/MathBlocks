namespace Supprocom.MathBlocks;

// One generic lift turns a scalar operation into its elementwise vector form. Each argument is a vector or a
// scalar; scalars are broadcast to every row and at least one argument is a vector. Row i is the source
// operation's own CoreCLR evaluation on row i of every vector argument and the scalar arguments unchanged. Rows
// where the source result is invalid hold the fill value; the validity sibling marks exactly the rows that were
// computed.
internal sealed class MathBlockElementwiseForm
{
    private readonly MathBlockOperation source;

    internal MathBlockElementwiseForm(MathBlockOperation source)
    {
        this.source = source;
        FormTypeResolver = ResolveFormType;
        ValidityTypeResolver = ResolveValidityType;
    }

    internal MathBlockOperation Source => source;

    internal MathBlockTypeResolver FormTypeResolver { get; }

    internal MathBlockTypeResolver ValidityTypeResolver { get; }

    internal int FormArity => source.Arity + 1;

    internal int ValidityArity => source.Arity;

    // The unit of the source result for the given argument types, which the fill must carry.
    internal MathBlockUnit ResolveSourceUnit(IReadOnlyList<MathBlockType> types) =>
        ResolveSourceType(types, out _).Unit;

    private MathBlockType ResolveFormType(IReadOnlyList<MathBlockType> types)
    {
        var sourceType = ResolveSourceType(types, out var rows);
        var fill = types[source.Arity];
        MathBlockTypeRules.RequireKind(fill, MathBlockValueKind.Scalar);
        if (fill.Unit != sourceType.Unit)
            throw new InvalidOperationException("The fill unit must equal the elementwise result unit.");
        return MathBlockType.Vector(sourceType.Unit, rows);
    }

    private MathBlockType ResolveValidityType(IReadOnlyList<MathBlockType> types)
    {
        _ = ResolveSourceType(types, out var rows);
        return MathBlockType.BooleanVector(rows);
    }

    internal MathBlockValue EvaluateForm(IReadOnlyList<MathBlockValue> inputs)
    {
        var type = FormTypeResolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
        if (!TryResolveCount(inputs, type, out var count, out var invalid))
            return invalid;
        var values = new double[count];
        Run(inputs, count, inputs[source.Arity].AsScalar(), values, null);
        return MathBlockValue.Vector(values, type.Unit, true);
    }

    internal MathBlockValue EvaluateValidity(IReadOnlyList<MathBlockValue> inputs)
    {
        var type = ValidityTypeResolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
        if (!TryResolveCount(inputs, type, out var count, out var invalid))
            return invalid;
        var valid = new bool[count];
        Run(inputs, count, 0d, null, valid);
        return MathBlockValue.BooleanVector(valid, true);
    }

    // A vector argument stands for one scalar of its unit per row, so the source resolver sees the row types. Equal
    // lengths are checked per evaluation, and unequal lengths give an invalid result rather than a type error.
    private MathBlockType ResolveSourceType(IReadOnlyList<MathBlockType> types, out int rows)
    {
        var sourceTypes = new MathBlockType[source.Arity];
        rows = 0;
        var vectors = 0;
        var consistent = true;
        for (var index = 0; index < source.Arity; index++)
        {
            var type = types[index];
            if (type.Kind != MathBlockValueKind.Vector)
            {
                sourceTypes[index] = type;
                continue;
            }
            vectors++;
            if (type.Rows > 0)
            {
                if (rows == 0)
                    rows = type.Rows;
                else if (rows != type.Rows)
                    consistent = false;
            }
            sourceTypes[index] = MathBlockType.Scalar(type.Unit);
        }
        if (vectors == 0)
            throw new InvalidOperationException("An elementwise form needs at least one vector argument.");
        if (!consistent)
            rows = 0;
        var output = source.ResolveOutputType(sourceTypes);
        MathBlockTypeRules.RequireKind(output, MathBlockValueKind.Scalar);
        return output;
    }

    private bool TryResolveCount(
        IReadOnlyList<MathBlockValue> inputs,
        MathBlockType type,
        out int count,
        out MathBlockValue invalid)
    {
        count = -1;
        for (var index = 0; index < source.Arity; index++)
        {
            if (inputs[index].Type.Kind != MathBlockValueKind.Vector)
                continue;
            var length = inputs[index].AsVector().Count;
            if (count < 0)
            {
                count = length;
            }
            else if (count != length)
            {
                invalid = MathBlockValue.Invalid(type, "The elementwise vector lengths differ.");
                return false;
            }
        }
        invalid = default;
        return true;
    }

    // One reusable argument array holds the scalar arguments and, per row, the current row of each vector
    // argument. Only this call sees it; the source evaluator reads it and returns a fresh scalar result. All state
    // is local, so concurrent evaluations are independent.
    private void Run(
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var rowInputs = new MathBlockValue[source.Arity];
        var vectors = new MathBlockVector?[source.Arity];
        var units = new MathBlockUnit[source.Arity];
        for (var index = 0; index < source.Arity; index++)
        {
            if (inputs[index].Type.Kind == MathBlockValueKind.Vector)
            {
                vectors[index] = inputs[index].AsVector();
                units[index] = inputs[index].Type.Unit;
            }
            else
            {
                rowInputs[index] = inputs[index];
            }
        }

        for (var row = 0; row < count; row++)
        {
            for (var index = 0; index < vectors.Length; index++)
            {
                if (vectors[index] is { } vector)
                    rowInputs[index] = MathBlockValue.Scalar(vector[row], units[index]);
            }
            var computed = EvaluateRow(rowInputs, out var value);
            if (valid is not null)
                valid[row] = computed;
            if (values is not null)
                values[row] = computed ? value : fill;
        }
    }

    // One row: the source operation's own CoreCLR evaluation on the row's scalar arguments. Returns whether the
    // source result is valid (the row is computed) and its value, or 0 when it is not. The form, the sibling and the
    // fused expression's elementwise rows all evaluate their rows here.
    internal bool EvaluateRow(MathBlockValue[] rowInputs, out double value)
    {
        var result = source.Evaluate(rowInputs);
        value = result.IsValid ? result.AsScalar() : 0d;
        return result.IsValid;
    }
}
