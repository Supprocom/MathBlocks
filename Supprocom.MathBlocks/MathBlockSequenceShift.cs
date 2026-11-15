namespace Supprocom.MathBlocks;

// The value and the validity form of sequence.lead and sequence.lag share this one core. The inputs are the series x, its
// per-row availability, the counts of contiguous steps before each row, the offset k and, for the value form, the fill.
// The whole call is invalid when the lengths differ, when k is not an integer of at least 1, or when a count is not a
// non-negative integer. Otherwise every row is either available (the shifted value and true) or unavailable (the fill and false).
internal static class MathBlockSequenceShift
{
    private const double SampleFill = -1d;

    internal static MathBlockOperation Create(string identifier, bool lead, bool validity, MathBlockCausalityInfo causality)
    {
        MathBlockTypeResolver resolver = types => ResolveType(types, validity);
        var sample = CreateSample(validity);
        var operation = MathBlockOperationFactory.Create(
            identifier,
            sample.Length,
            resolver,
            inputs => Evaluate(inputs, resolver, lead, validity),
            sample,
            CreateExpected(lead, validity),
            1e-12,
            64,
            causality);
        return operation;
    }

    // The sample: a series of three chained rows, a gap, one row with unavailable x, a series start and a tail.
    private static MathBlockValue[] CreateSample(bool validity)
    {
        var inputs = new List<MathBlockValue>(5)
        {
            MathBlockValue.Vector([10d, 20d, 30d, 40d, 50d, 60d]),
            MathBlockValue.BooleanVector([true, true, false, true, false, true]),
            MathBlockValue.Vector([0d, 1d, 2d, 0d, 1d, 2d]),
            MathBlockValue.Scalar(1d)
        };
        if (!validity)
            inputs.Add(MathBlockValue.Scalar(SampleFill));
        return [.. inputs];
    }

    private static MathBlockValue CreateExpected(bool lead, bool validity)
    {
        if (lead)
        {
            return validity
                ? MathBlockValue.BooleanVector([true, false, false, false, true, false])
                : MathBlockValue.Vector([20d, SampleFill, SampleFill, SampleFill, 60d, SampleFill]);
        }
        return validity
            ? MathBlockValue.BooleanVector([false, true, true, false, true, false])
            : MathBlockValue.Vector([SampleFill, 10d, 20d, SampleFill, 40d, SampleFill]);
    }

    private static MathBlockType ResolveType(IReadOnlyList<MathBlockType> types, bool validity)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.BooleanVector);
        MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireDimensionless(types[2]);
        MathBlockTypeRules.RequireKind(types[3], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[3]);
        if (validity)
            return MathBlockType.BooleanVector(types[0].Rows);
        MathBlockTypeRules.RequireKind(types[4], MathBlockValueKind.Scalar);
        if (types[4].Unit != types[0].Unit)
            throw new InvalidOperationException("The fill unit must equal the series unit.");
        return MathBlockType.Vector(types[0].Unit, types[0].Rows);
    }

    private static MathBlockValue Evaluate(
        IReadOnlyList<MathBlockValue> inputs,
        MathBlockTypeResolver resolver,
        bool lead,
        bool validity)
    {
        var x = inputs[0].AsVector();
        var flags = inputs[1].AsBooleanVector();
        var counts = inputs[2].AsVector();
        var offset = inputs[3].AsScalar();
        var count = x.Count;
        if (flags.Count != count || counts.Count != count)
            return MathBlockOperationFactory.Invalid(resolver, inputs, "The series, its availability and its counts differ in length.");
        if (!(offset >= 1d) || offset != Math.Truncate(offset))
            return MathBlockOperationFactory.Invalid(resolver, inputs, "The offset is not an integer of at least 1.");
        var countSpan = counts.Span;
        for (var index = 0; index < countSpan.Length; index++)
        {
            var steps = countSpan[index];
            if (!(steps >= 0d) || steps != Math.Truncate(steps))
                return MathBlockOperationFactory.Invalid(resolver, inputs, "A count is not a non-negative integer.");
        }

        // An offset of count or more leaves every row unavailable, so it is limited to count and the arithmetic stays in int.
        var distance = (int)Math.Min(offset, count);
        var valid = new bool[count];
        if (validity)
        {
            if (lead)
                MathBlockVectorMath.SequenceLeadValidity(x.Span, flags.Span, countSpan, distance, valid);
            else
                MathBlockVectorMath.SequenceLagValidity(x.Span, flags.Span, countSpan, distance, valid);
            return MathBlockValue.BooleanVector(valid, true);
        }

        var fill = inputs[4].AsScalar();
        var values = new double[count];
        if (lead)
            MathBlockVectorMath.SequenceLead(x.Span, flags.Span, countSpan, distance, fill, values, valid);
        else
            MathBlockVectorMath.SequenceLag(x.Span, flags.Span, countSpan, distance, fill, values, valid);
        return MathBlockValue.Vector(values, inputs[0].Type.Unit, true);
    }
}
