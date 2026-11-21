namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>The inputs of the elementwise form and of its validity sibling for a row function: the operand vectors, and for the form the fill scalar.</summary>
internal static class RowFunctionForms
{
    /// <summary>Builds the inputs of <c>elementwise.&lt;source&gt;</c>: the operands and the fill.</summary>
    internal static MathBlockValue[] FormInputs(RowFunctionOp function, ProofSet set)
    {
        var fill = MathBlockValue.Scalar(RowFunctionHarness.Fill);
        if (function.Arity == 1)
            return [MathBlockValue.Vector(set.First), fill];
        return [MathBlockValue.Vector(set.First), MathBlockValue.Vector(set.Second), fill];
    }

    /// <summary>Builds the inputs of <c>elementwise-valid.&lt;source&gt;</c>: the operands.</summary>
    internal static MathBlockValue[] ValidityInputs(RowFunctionOp function, ProofSet set)
    {
        if (function.Arity == 1)
            return [MathBlockValue.Vector(set.First)];
        return [MathBlockValue.Vector(set.First), MathBlockValue.Vector(set.Second)];
    }

    /// <summary>The values of the row sum: row r adds <paramref name="count"/> values, alternating between the two operands and starting at row r of the set.</summary>
    internal static float[] SumValues(ProofSet set, int count)
    {
        var values = new float[set.First.Length * count];
        for (var row = 0; row < set.First.Length; row++)
        {
            for (var index = 0; index < count; index++)
            {
                var source = index % 2 == 0 ? set.First : set.Second;
                values[row * count + index] = source[(row + index) % source.Length];
            }
        }

        return values;
    }
}
