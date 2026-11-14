using System.Reflection;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Binds the public MathBlockFusedExpression.EvaluateCoreCLR signature that 0.6.1 shipped, which needs no CUDA device.</summary>
public sealed class MathBlockFusedExpressionBinaryCompatibilityTests
{
    /// <summary>Verifies EvaluateCoreCLR(inputs, validity = null) of 0.6.1 still exists with its exact parameter types, optional validity parameter and return type.</summary>
    // A binary compiled against 0.6.1 binds this method by name and parameter types. Adding optional parameters to it changes the
    // parameter list and breaks that binding, so the extra parameters live in a separate overload.
    [Fact]
    public void EvaluateCoreClrKeepsItsShippedSignature()
    {
        var method = typeof(MathBlockFusedExpression).GetMethod(
            nameof(MathBlockFusedExpression.EvaluateCoreCLR),
            BindingFlags.Public | BindingFlags.Instance,
            binder: null,
            types: [typeof(IReadOnlyDictionary<string, MathBlockValue>), typeof(IReadOnlyDictionary<string, MathBlockValue>)],
            modifiers: null);

        Assert.NotNull(method);
        Assert.Equal(typeof(MathBlockFusedResult), method.ReturnType);

        var parameters = method.GetParameters();
        Assert.Equal(2, parameters.Length);
        Assert.Equal("inputs", parameters[0].Name);
        Assert.Equal(typeof(IReadOnlyDictionary<string, MathBlockValue>), parameters[0].ParameterType);
        Assert.False(parameters[0].IsOptional);
        Assert.Equal("validity", parameters[1].Name);
        Assert.Equal(typeof(IReadOnlyDictionary<string, MathBlockValue>), parameters[1].ParameterType);
        Assert.True(parameters[1].IsOptional);
        Assert.Null(parameters[1].DefaultValue);
    }
}
