namespace Supprocom.MathBlocks;

// The validity sibling reads the validity rows of the same core as the form.
public static partial class MathBlockVectorMath
{
    internal static MathBlockValue PrefixDifferenceValidity(IReadOnlyList<MathBlockValue> inputs)
    {
        var rows = PrefixDifferenceCompute(
            inputs[0].AsVector(),
            inputs[1].AsBooleanVector(),
            inputs[2].AsVector(),
            inputs[3].AsScalar(),
            inputs[4].AsScalar(),
            0f,
            false,
            true);
        return rows.Reason is { } reason
            ? MathBlockOperationFactory.Invalid(PrefixDifferenceValidityType, inputs, reason)
            : MathBlockValue.BooleanVector(rows.Valid, true);
    }
}
