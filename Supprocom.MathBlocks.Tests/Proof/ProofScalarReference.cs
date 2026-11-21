namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The CoreCLR result of a row function for one row: the row is valid when every argument is finite and the scalar operation gives a valid (finite) result, and the value is
/// the scalar operation's. A non-finite argument cannot be held by a value, so it makes the row invalid without calling the operation.
/// </summary>
internal static class ProofScalarReference
{
    private static readonly Dictionary<string, MathBlockOperation> Operations = new(StringComparer.Ordinal);

    /// <summary>Evaluates one row; <paramref name="value"/> is meaningful only when the row is valid.</summary>
    internal static bool Apply(RowFunctionOp function, float a, float b, out float value)
    {
        value = 0f;
        if (!float.IsFinite(a) || (function.Arity == 2 && !float.IsFinite(b)))
            return false;
        if (!Operations.TryGetValue(function.ScalarIdentifier, out var operation))
        {
            operation = MathBlockCatalog.Standard.Get(function.ScalarIdentifier);
            Operations.Add(function.ScalarIdentifier, operation);
        }

        var inputs = new MathBlockValue[function.Arity];
        inputs[0] = MathBlockValue.Scalar(a);
        if (function.Arity == 2)
            inputs[1] = MathBlockValue.Scalar(b);
        var result = operation.Evaluate(inputs);
        if (!result.IsValid)
            return false;
        value = result.AsScalar();
        return true;
    }

    /// <summary>
    /// Evaluates a row sum as a CoreCLR left-to-right chain of the add operation from 0.0: the first step with a non-finite term, or a non-finite partial sum, ends the row as invalid.
    /// </summary>
    internal static bool Sum(float[] values, int offset, int count, out float value)
    {
        value = 0f;
        var sum = 0f;
        for (var index = 0; index < count; index++)
        {
            if (!Apply(RowFunctionOp.Add, sum, values[offset + index], out sum))
                return false;
        }

        value = sum;
        return true;
    }
}
