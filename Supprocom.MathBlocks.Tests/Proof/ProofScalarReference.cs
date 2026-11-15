namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The CoreCLR result of a row function for one row: the row is valid when every argument is finite and the scalar operation gives a valid (finite) result, and the value is
/// the scalar operation's. A non-finite argument cannot be held by a value, so it makes the row invalid without calling the operation.
/// </summary>
internal static class ProofScalarReference
{
    private static readonly Dictionary<string, MathBlockOperation> Operations = new(StringComparer.Ordinal);

    /// <summary>Evaluates one row; <paramref name="value"/> is meaningful only when the row is valid.</summary>
    internal static bool Apply(RowFunctionOp function, double a, double b, out double value)
    {
        value = 0d;
        if (!double.IsFinite(a) || (function.Arity == 2 && !double.IsFinite(b)))
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
    internal static bool Sum(double[] values, int offset, int count, out double value)
    {
        value = 0d;
        var sum = 0d;
        for (var index = 0; index < count; index++)
        {
            if (!Apply(RowFunctionOp.Add, sum, values[offset + index], out sum))
                return false;
        }

        value = sum;
        return true;
    }
}
