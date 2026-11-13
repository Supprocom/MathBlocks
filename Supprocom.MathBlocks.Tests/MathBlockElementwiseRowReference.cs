using System.Reflection;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// CoreCLR's elementwise row, for argument rows that a <see cref="MathBlockValue"/> cannot hold (a vector holds finite numbers only). The rows
/// run through the elementwise form's own row function, which receives each argument as a scalar value: a non-finite argument is an invalid
/// input and the row is invalid before the source operation is evaluated.
/// </summary>
internal static class MathBlockElementwiseRowReference
{
    private static readonly Assembly Library = typeof(MathBlockOperation).Assembly;

    /// <summary>Gets whether the row is computed and its value, for the source arguments of one row.</summary>
    internal static (bool Computed, double Value) Row(string sourceIdentifier, params double[] arguments)
    {
        var source = MathBlockCatalog.Standard.Get(sourceIdentifier);
        var elementwise = Library.GetType("Supprocom.MathBlocks.ElementwiseMathBlocks", throwOnError: true)!;
        var form = Library.GetType("Supprocom.MathBlocks.MathBlockElementwiseForm", throwOnError: true)!;
        var formOperation = MathBlockCatalog.Standard.Get("elementwise." + sourceIdentifier);
        object?[] lookup = [formOperation, null];
        var found = (bool)elementwise.GetMethod("TryGetLift", BindingFlags.Static | BindingFlags.NonPublic)!.Invoke(null, lookup)!;
        Assert.True(found, sourceIdentifier);
        var rowInputs = arguments.Select(argument => MathBlockValue.Scalar(argument)).ToArray();
        Assert.Equal(source.Arity, rowInputs.Length);
        object?[] call = [rowInputs, 0d];
        var computed = (bool)form.GetMethod(
            "EvaluateRow",
            BindingFlags.Instance | BindingFlags.NonPublic,
            [typeof(MathBlockValue[]), typeof(double).MakeByRefType()])!.Invoke(lookup[1], call)!;
        return (computed, (double)call[1]!);
    }
}
