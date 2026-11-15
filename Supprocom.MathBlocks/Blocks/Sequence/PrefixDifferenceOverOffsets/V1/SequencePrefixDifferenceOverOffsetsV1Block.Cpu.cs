namespace Supprocom.MathBlocks;

// The core of sequence.prefix-difference-over-offsets@1 and of its validity sibling: both evaluate this one function and
// read its value and validity rows. A segment starts at row 0 and at every row whose count is 0. Inside a segment the prefix
// P[0] is 0 and each later P adds, left to right, the row's value, or 0 when the row is unavailable; U counts the
// unavailable rows. Row t is the difference P[t + end + 1] - P[t + start] of the prefix of t's own segment. It is valid when
// both ends lie in that segment, no unavailable row lies between them (U is equal at both ends) and the difference is
// finite. The sum is never -0 (it starts at +0 and +0 absorbs -0), so adding 0 for an unavailable row leaves it unchanged.
public static partial class MathBlockVectorMath
{
    private const string PrefixDifferenceRowCountsDiffer = "The input row counts must be equal.";

    // The result of one call: the values with the fill on unavailable rows, and the per-row validity. Reason is set, and the
    // rows are empty, when the whole call is invalid.
    internal readonly record struct PrefixDifferenceRows(double[] Values, bool[] Valid, string? Reason);

    internal static PrefixDifferenceRows PrefixDifferenceCompute(
        MathBlockVector values,
        MathBlockBooleanVector available,
        MathBlockVector counts,
        double start,
        double end,
        double fill)
    {
        var count = values.Count;
        if (available.Count != count || counts.Count != count)
            return PrefixDifferenceWhole(PrefixDifferenceRowCountsDiffer);
        if (!double.IsFinite(start) || !double.IsFinite(end) || start != Math.Floor(start) || end != Math.Floor(end))
            return PrefixDifferenceWhole("The start and end offsets must be integers.");
        if (start > end)
            return PrefixDifferenceWhole("The start offset must not exceed the end offset.");
        for (var row = 0; row < count; row++)
        {
            var rowCount = counts[row];
            if (!double.IsFinite(rowCount) || rowCount < 0d || rowCount != Math.Floor(rowCount))
                return PrefixDifferenceWhole("Every count must be a non-negative integer.");
        }

        var segmentStart = new int[count];
        var segmentEnd = new int[count];
        var before = new double[count];
        var after = new double[count];
        var missingBefore = new int[count];
        var missingAfter = new int[count];
        var sum = 0d;
        var missing = 0;
        var first = 0;
        for (var row = 0; row < count; row++)
        {
            if (row == 0 || counts[row] == 0d)
            {
                first = row;
                sum = 0d;
                missing = 0;
            }

            segmentStart[row] = first;
            before[row] = sum;
            missingBefore[row] = missing;
            if (available[row])
                sum += values[row];
            else
                missing++;
            after[row] = sum;
            missingAfter[row] = missing;
        }

        var last = count;
        for (var row = count - 1; row >= 0; row--)
        {
            segmentEnd[row] = last;
            if (row == segmentStart[row])
                last = row;
        }

        var result = new double[count];
        var valid = new bool[count];
        for (var row = 0; row < count; row++)
        {
            result[row] = fill;
            var low = row + start;
            var high = row + end;
            if (low < segmentStart[row] || high >= segmentEnd[row])
                continue;
            var lowRow = (int)low;
            var highRow = (int)high;
            if (missingBefore[lowRow] != missingAfter[highRow])
                continue;
            var difference = after[highRow] - before[lowRow];
            if (!double.IsFinite(difference))
                continue;
            result[row] = difference;
            valid[row] = true;
        }

        return new PrefixDifferenceRows(result, valid, null);
    }

    // The type of the form (validity false) and of its validity sibling: the series length is the first one any of the three
    // series inputs knows, and the three must agree where they know it.
    internal static MathBlockType PrefixDifferenceResolveType(IReadOnlyList<MathBlockType> types, bool validity)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.BooleanVector);
        MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireDimensionless(types[2]);
        MathBlockTypeRules.RequireKind(types[3], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[3]);
        MathBlockTypeRules.RequireKind(types[4], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[4]);
        if (!validity)
        {
            MathBlockTypeRules.RequireKind(types[5], MathBlockValueKind.Scalar);
            if (types[5].Unit != types[0].Unit)
                throw new InvalidOperationException("The input units must be equal.");
        }

        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[2]);
        MathBlockTypeRules.RequireCompatibleShape(types[1], types[2]);
        var rows = types[0].Rows != 0 ? types[0].Rows : types[1].Rows != 0 ? types[1].Rows : types[2].Rows;
        return validity ? MathBlockType.BooleanVector(rows) : MathBlockType.Vector(types[0].Unit, rows);
    }

    internal static MathBlockValue PrefixDifferenceForm(IReadOnlyList<MathBlockValue> inputs)
    {
        var rows = PrefixDifferenceCompute(
            inputs[0].AsVector(),
            inputs[1].AsBooleanVector(),
            inputs[2].AsVector(),
            inputs[3].AsScalar(),
            inputs[4].AsScalar(),
            inputs[5].AsScalar());
        return rows.Reason is { } reason
            ? MathBlockOperationFactory.Invalid(PrefixDifferenceFormType, inputs, reason)
            : MathBlockValue.Vector(rows.Values, inputs[0].Type.Unit, true);
    }

    internal static MathBlockType PrefixDifferenceFormType(IReadOnlyList<MathBlockType> types) => PrefixDifferenceResolveType(types, false);

    internal static MathBlockType PrefixDifferenceValidityType(IReadOnlyList<MathBlockType> types) => PrefixDifferenceResolveType(types, true);

    private static PrefixDifferenceRows PrefixDifferenceWhole(string reason) => new([], [], reason);
}
