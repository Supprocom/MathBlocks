namespace Supprocom.MathBlocks;

// The shared parts of sequence.first-true-offset, sequence.sum-over-offsets and sequence.maximum-over-offsets and of their -valid
// siblings. A value operation and its sibling run the same row function (MathBlockVectorMath.FirstTrueOffsetRow and its two
// twins), so the values and the per-row validity always come from one evaluation. The inputs that can be unavailable per row
// arrive as a vector plus a Boolean vector of validity; counts[t] is the number of contiguous rows before row t.
internal static partial class VectorMathBlocks
{
    private const string OffsetRowCountsDiffer = "The input row counts must be equal.";
    private const string OffsetCountsInvalid = "The contiguity counts must be non-negative integers.";
    private const string OffsetRangeInvalid = "The offsets must be integers with start not above end.";
    private const float OffsetSampleFill = -1f;

    private static readonly MathBlockValue offsetSampleValidity = MathBlockValue.BooleanVector([true, true, true, true, true]);
    private static readonly MathBlockValue offsetSampleCounts = MathBlockValue.Vector([0f, 1f, 2f, 3f, 4f]);

    private enum OffsetKind
    {
        FirstTrue,
        Sum,
        Maximum
    }

    // With start 0 and end 1, row 0 and row 3 find no match, row 1 matches at offset 1, row 2 at offset 0, and row 4 reaches past the series.
    internal static MathBlockOperation CreateFirstTrueOffset(bool validity)
    {
        var series = MathBlockValue.Vector([0f, 0f, 1f, 0f, 0f]);
        MathBlockValue[] sample = validity
            ? [series, offsetSampleValidity, offsetSampleCounts, MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f)]
            : [series, offsetSampleValidity, offsetSampleCounts, MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f), MathBlockValue.Scalar(99f), MathBlockValue.Scalar(OffsetSampleFill)];
        var expected = validity
            ? MathBlockValue.BooleanVector([true, true, true, true, false])
            : MathBlockValue.Vector([99f, 1f, 0f, 99f, OffsetSampleFill]);
        return CreateOffsetOperation("sequence.first-true-offset", OffsetKind.FirstTrue, validity, sample, expected);
    }

    // The sum of x[t] and x[t + 1], with no row after the last.
    internal static MathBlockOperation CreateSumOverOffsets(bool validity)
    {
        var series = MathBlockValue.Vector([1f, 2f, 3f, 4f, 5f]);
        MathBlockValue[] sample = validity
            ? [series, offsetSampleValidity, offsetSampleCounts, MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f)]
            : [series, offsetSampleValidity, offsetSampleCounts, MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f), MathBlockValue.Scalar(OffsetSampleFill)];
        var expected = validity
            ? MathBlockValue.BooleanVector([true, true, true, true, false])
            : MathBlockValue.Vector([3f, 5f, 7f, 9f, OffsetSampleFill]);
        return CreateOffsetOperation("sequence.sum-over-offsets", OffsetKind.Sum, validity, sample, expected);
    }

    // The maximum of x[t - 1], x[t] and x[t + 1], with no row before the first or after the last.
    internal static MathBlockOperation CreateMaximumOverOffsets(bool validity)
    {
        var series = MathBlockValue.Vector([1f, 5f, 2f, 4f, 3f]);
        MathBlockValue[] sample = validity
            ? [series, offsetSampleValidity, offsetSampleCounts, MathBlockValue.Scalar(-1f), MathBlockValue.Scalar(1f)]
            : [series, offsetSampleValidity, offsetSampleCounts, MathBlockValue.Scalar(-1f), MathBlockValue.Scalar(1f), MathBlockValue.Scalar(OffsetSampleFill)];
        var expected = validity
            ? MathBlockValue.BooleanVector([false, true, true, true, false])
            : MathBlockValue.Vector([OffsetSampleFill, 5f, 5f, 4f, OffsetSampleFill]);
        return CreateOffsetOperation("sequence.maximum-over-offsets", OffsetKind.Maximum, validity, sample, expected);
    }

    private static MathBlockOperation CreateOffsetOperation(
        string identifier,
        OffsetKind kind,
        bool validity,
        MathBlockValue[] sample,
        MathBlockValue expected) => MathBlockOperationFactory.Create(
        validity ? identifier + "-valid" : identifier,
        sample.Length,
        types => OffsetType(types, kind, validity),
        inputs => EvaluateOffsets(inputs, kind, validity),
        sample,
        expected,
        1e-12f,
        64);

    // The operands are x (or the predicate p), its validity, the counts, start and end; a value operation then takes the fill, and
    // first-true takes the no-match offset before it. The output has x's length and is a Boolean vector for a -valid sibling.
    // Its unit is x's for sum and maximum, and none for first-true.
    private static MathBlockType OffsetType(IReadOnlyList<MathBlockType> types, OffsetKind kind, bool validity)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.BooleanVector);
        MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireDimensionless(types[2]);
        for (var index = 3; index <= 4; index++)
            RequireDimensionlessScalar(types[index]);
        if (!validity && kind == OffsetKind.FirstTrue)
        {
            RequireDimensionlessScalar(types[5]);
            RequireDimensionlessScalar(types[6]);
        }
        else if (!validity)
        {
            MathBlockTypeRules.RequireKind(types[5], MathBlockValueKind.Scalar);
            if (types[5].Unit != types[0].Unit)
                throw new InvalidOperationException("The input units must be equal.");
        }
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[2]);
        MathBlockTypeRules.RequireCompatibleShape(types[1], types[2]);
        var rows = types[0].Rows != 0 ? types[0].Rows : types[1].Rows != 0 ? types[1].Rows : types[2].Rows;
        if (validity)
            return MathBlockType.BooleanVector(rows);
        return MathBlockType.Vector(kind == OffsetKind.FirstTrue ? default : types[0].Unit, rows);
    }

    private static void RequireDimensionlessScalar(MathBlockType type)
    {
        MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(type);
    }

    private static MathBlockValue EvaluateOffsets(IReadOnlyList<MathBlockValue> inputs, OffsetKind kind, bool validity)
    {
        var x = inputs[0].AsVector();
        var flags = inputs[1].AsBooleanVector();
        var counts = inputs[2].AsVector();
        string? reason = null;
        if (flags.Count != x.Count || counts.Count != x.Count)
            reason = OffsetRowCountsDiffer;
        else if (!MathBlockVectorMath.CountsAreValid(counts.Span))
            reason = OffsetCountsInvalid;
        if (reason is not null || !TryReadOffsets(inputs, out var start, out var end))
        {
            return MathBlockOperationFactory.Invalid(
                types => OffsetType(types, kind, validity), inputs, reason ?? OffsetRangeInvalid);
        }
        return validity
            ? EvaluateOffsetValidity(inputs, kind, start, end)
            : EvaluateOffsetValues(inputs, kind, start, end);
    }

    private static bool TryReadOffsets(IReadOnlyList<MathBlockValue> inputs, out int start, out int end)
    {
        end = 0;
        return MathBlockVectorMath.TryReadOffset(inputs[3].AsScalar(), out start) &&
               MathBlockVectorMath.TryReadOffset(inputs[4].AsScalar(), out end) &&
               start <= end;
    }

    private static MathBlockValue EvaluateOffsetValidity(IReadOnlyList<MathBlockValue> inputs, OffsetKind kind, int start, int end)
    {
        var x = inputs[0].AsVector().Span;
        var flags = inputs[1].AsBooleanVector().Span;
        var counts = inputs[2].AsVector().Span;
        var rowValid = new bool[x.Length];
        if (kind == OffsetKind.FirstTrue)
            MathBlockVectorMath.FirstTrueOffsetValidity(x, flags, counts, start, end, rowValid);
        else if (kind == OffsetKind.Sum)
            MathBlockVectorMath.SumOverOffsetsValidity(x, flags, counts, start, end, rowValid);
        else
            MathBlockVectorMath.MaximumOverOffsetsValidity(x, flags, counts, start, end, rowValid);
        return MathBlockValue.BooleanVector(rowValid, true);
    }

    private static MathBlockValue EvaluateOffsetValues(IReadOnlyList<MathBlockValue> inputs, OffsetKind kind, int start, int end)
    {
        var x = inputs[0].AsVector().Span;
        var flags = inputs[1].AsBooleanVector().Span;
        var counts = inputs[2].AsVector().Span;
        var fill = inputs[inputs.Count - 1].AsScalar();
        // first-true-offset writes every row of both arrays, so its value array needs no clearing.
        var values = kind == OffsetKind.FirstTrue ? GC.AllocateUninitializedArray<float>(x.Length) : new float[x.Length];
        var rowValid = new bool[x.Length];
        if (kind == OffsetKind.FirstTrue)
        {
            MathBlockVectorMath.FirstTrueOffsetValues(x, flags, counts, start, end, inputs[5].AsScalar(), fill, values, rowValid);
            return MathBlockValue.Vector(values, default, true);
        }
        if (kind == OffsetKind.Sum)
            MathBlockVectorMath.SumOverOffsetsValues(x, flags, counts, start, end, fill, values, rowValid);
        else
            MathBlockVectorMath.MaximumOverOffsetsValues(x, flags, counts, start, end, fill, values, rowValid);
        return MathBlockValue.Vector(values, inputs[0].Type.Unit, true);
    }
}
