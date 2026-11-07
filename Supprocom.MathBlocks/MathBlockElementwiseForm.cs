using System.Runtime.Intrinsics;

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
        if (count > 0 && TryRunKernel(inputs, count, fill, values, valid))
            return;

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

    // Fast path for a source built by MathBlockOperationFactory.ScalarUnary or ScalarBinary. It returns false, having
    // written nothing, whenever it cannot show that it gives exactly the outcome of the per-row path below.
    //
    // Equivalence argument. For such a source, Evaluate(row) is, in order:
    //   1. RequireArity: the arity is the source arity on every row.
    //   2. outputType = resolver(row input types). A vector argument contributes Scalar(unit) on every row and a
    //      scalar argument its own type, so the types, and therefore outputType, are the same on every row. They are
    //      resolved once here, from the same types, so a resolver exception is the same exception.
    //   3. Any invalid input gives an invalid row. A row input is MathBlockValue.Scalar(vector[row], unit), which is
    //      invalid exactly when vector[row] is not finite: the loop below tests that per row. An invalid scalar
    //      argument makes every row invalid, so that case is left to the per-row path.
    //   4. The evaluator computes MathBlockValue.Scalar(kernel(inputs), outputType.Unit), where kernel is the very
    //      function the factory stored in UnaryKernel or BinaryKernel. That value is valid exactly when the kernel
    //      result is finite, and then holds the result. The loop applies the same kernel to the same doubles and
    //      tests Math.IsFinite on the result. The three exceptions Evaluate converts to an invalid row
    //      (ArithmeticException, ArgumentOutOfRangeException, IndexOutOfRangeException) are caught here the same way;
    //      any other exception propagates as before.
    //   5. outputType.Accepts(result.Type) is checked on a result whose type is Scalar(outputType.Unit) whether the
    //      result is valid or not, so it has one outcome for the whole run. It is evaluated once; if it would throw,
    //      this method returns false and the per-row path throws on row 0 as before.
    //   6. The final type normalisation keeps IsValid, the only thing EvaluateRow reads.
    // Arguments of any kind other than Scalar (after the vector-to-row mapping) are left to the per-row path.
    private bool TryRunKernel(
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var arity = source.Arity;
        var unary = source.UnaryKernel;
        var binary = source.BinaryKernel;
        if ((arity == 1 && unary is null) || (arity == 2 && binary is null) || arity is not (1 or 2))
            return false;

        var types = new MathBlockType[arity];
        var vectors = new MathBlockVector?[arity];
        var constants = new double[arity];
        for (var index = 0; index < arity; index++)
        {
            var input = inputs[index];
            if (input.Type.Kind == MathBlockValueKind.Vector)
            {
                vectors[index] = input.AsVector();
                types[index] = MathBlockType.Scalar(input.Type.Unit);
            }
            else if (input.Type.Kind == MathBlockValueKind.Scalar && input.IsValid)
            {
                constants[index] = input.AsScalar();
                types[index] = input.Type;
            }
            else
            {
                return false;
            }
        }

        var outputType = source.ResolveOutputType(types);
        if (!outputType.Accepts(MathBlockType.Scalar(outputType.Unit)))
            return false;

        var first = vectors[0] is { } firstVector ? firstVector.Span : default;
        var second = arity == 2 && vectors[1] is { } secondVector ? secondVector.Span : default;
        var firstIsVector = vectors[0] is not null;
        var secondIsVector = arity == 2 && vectors[1] is not null;
        // Block path for scalar.minimum and scalar.maximum, recognised by the kernel being that very function. It is a
        // separate method so that the loop below, which every other kernel runs, stays small.
        if (arity == 2 && MathBlockSimd.UseBlocks && count >= MathBlockSimd.BlockWidth)
        {
            var kind = binary!.Equals((Func<double, double, double>)MathBlockScalar.Minimum) ? 1
                : binary.Equals((Func<double, double, double>)MathBlockScalar.Maximum) ? 2
                : 0;
            if (kind != 0)
            {
                RunBlocks(kind, first, second, firstIsVector, secondIsVector, constants, count, fill, values, valid);
                return true;
            }
        }

        RunRows(unary, binary, first, second, firstIsVector, secondIsVector, constants, count, fill, values, valid);
        return true;
    }

    // The per-row loop for every kernel that has no block path, one row per iteration.
    private static void RunRows(
        Func<double, double>? unary,
        Func<double, double, double>? binary,
        ReadOnlySpan<double> first,
        ReadOnlySpan<double> second,
        bool firstIsVector,
        bool secondIsVector,
        double[] constants,
        int count,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var arity = binary is null ? 1 : 2;
        var row = 0;
        while (row < count)
        {
            try
            {
                for (; row < count; row++)
                {
                    var x = firstIsVector ? first[row] : constants[0];
                    var y = secondIsVector ? second[row] : arity == 2 ? constants[1] : 0d;
                    var computed = Math.IsFinite(x) && (arity == 1 || Math.IsFinite(y));
                    var result = 0d;
                    if (computed)
                    {
                        result = arity == 1 ? unary!(x) : binary!(x, y);
                        computed = Math.IsFinite(result);
                    }
                    Store(row, computed, result, fill, values, valid);
                }
            }
            catch (Exception exception) when (exception is ArithmeticException or ArgumentOutOfRangeException or IndexOutOfRangeException)
            {
                Store(row, false, 0d, fill, values, valid);
                row++;
            }
        }
    }

    // Minimum (kind 1) or maximum (kind 2) over blocks. A block takes the vector path only when all its inputs are
    // finite (so none is NaN, which MinimumWithoutNaN and MaximumWithoutNaN require, and each row's input check
    // passes). Their results are one of the two operands, so they are finite and every row of the block holds exactly
    // Min or Max's value. Any other block, and the tail, run the per-row logic of TryRunKernel; neither Min nor Max
    // throws, so there is no exception handling here.
    private static void RunBlocks(
        int kind,
        ReadOnlySpan<double> first,
        ReadOnlySpan<double> second,
        bool firstIsVector,
        bool secondIsVector,
        double[] constants,
        int count,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var firstConstant = Vector256.Create(constants[0]);
        var secondConstant = Vector256.Create(constants[1]);
        var row = 0;
        for (; row <= count - MathBlockSimd.BlockWidth; row += MathBlockSimd.BlockWidth)
        {
            var left = firstIsVector ? Vector256.Create<double>(first[row..]) : firstConstant;
            var right = secondIsVector ? Vector256.Create<double>(second[row..]) : secondConstant;
            if (MathBlockSimd.BlockIsFinite(left) && MathBlockSimd.BlockIsFinite(right))
            {
                var block = kind == 1
                    ? MathBlockSimd.MinimumWithoutNaN(left, right)
                    : MathBlockSimd.MaximumWithoutNaN(left, right);
                if (values is not null)
                    block.CopyTo(values.AsSpan(row));
                if (valid is not null)
                    valid.AsSpan(row, MathBlockSimd.BlockWidth).Fill(true);
            }
            else
            {
                for (var offset = 0; offset < MathBlockSimd.BlockWidth; offset++)
                    RunRow(kind, first, second, firstIsVector, secondIsVector, constants, row + offset, fill, values, valid);
            }
        }
        for (; row < count; row++)
            RunRow(kind, first, second, firstIsVector, secondIsVector, constants, row, fill, values, valid);
    }

    private static void RunRow(
        int kind,
        ReadOnlySpan<double> first,
        ReadOnlySpan<double> second,
        bool firstIsVector,
        bool secondIsVector,
        double[] constants,
        int row,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var x = firstIsVector ? first[row] : constants[0];
        var y = secondIsVector ? second[row] : constants[1];
        var computed = Math.IsFinite(x) && Math.IsFinite(y);
        var result = computed ? (kind == 1 ? Math.Min(x, y) : Math.Max(x, y)) : 0d;
        Store(row, computed, result, fill, values, valid);
    }

    private static void Store(int row, bool computed, double result, double fill, double[]? values, bool[]? valid)
    {
        if (valid is not null)
            valid[row] = computed;
        if (values is not null)
            values[row] = computed ? result : fill;
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
