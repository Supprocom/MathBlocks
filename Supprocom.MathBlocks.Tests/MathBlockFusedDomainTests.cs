using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains the tests of the fused expression under domain options: CoreCLR without a device, and the CUDA kernel against it on the device.</summary>
public sealed class MathBlockFusedDomainTests
{
    private const string Form = "elementwise.special.regularized-incomplete-beta@1";
    private const string Sibling = "elementwise-valid.special.regularized-incomplete-beta@1";
    private const int Rows = 5;

    private static (MathBlockFusedExpression Expression, Dictionary<string, MathBlockValue> Inputs) BetaExpression()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector(length: Rows));
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var fill = builder.Input("fill", MathBlockType.Scalar());
        var program = builder
            .Output("values", builder.Apply("elementwise.special.regularized-incomplete-beta", 1, x, left, right, fill))
            .Output("valid", builder.Apply("elementwise-valid.special.regularized-incomplete-beta", 1, x, left, right))
            .Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector(Enumerable.Repeat(0.5d, Rows)),
            ["left"] = MathBlockValue.Scalar(1e6d),
            ["right"] = MathBlockValue.Scalar(1e6d),
            ["fill"] = MathBlockValue.Scalar(-1d)
        };
        return (MathBlockFusedExpression.Create(program), inputs);
    }

    /// <summary>Gets the option sets: the defaults, a policy, and an iteration count that converges.</summary>
    public static TheoryData<string> OptionSets => ["defaults", "invalid", "converging", "tolerance"];

    private static MathBlockDomainOptions Options(string name) => name switch
    {
        "invalid" => new() { IncompleteBetaNonConvergence = MathBlockNonConvergencePolicy.Invalid },
        "converging" => new() { IncompleteBetaMaximumIterations = 513 },
        "tolerance" => new() { IncompleteBetaTolerance = 1d },
        _ => MathBlockDomainOptions.Default
    };

    /// <summary>Verifies the CoreCLR fused evaluation applies the domain options to its elementwise rows and counts the non-converged rows by identity.</summary>
    [Fact]
    public void TheFusedCoreCLREvaluationAppliesTheDomainOptions()
    {
        var (expression, inputs) = BetaExpression();

        var defaults = expression.EvaluateCoreCLR(inputs);
        var invalid = expression.EvaluateCoreCLR(inputs, null, Options("invalid"), MathBlocksCudaOptions.Default);
        var converging = expression.EvaluateCoreCLR(inputs, null, Options("converging"), MathBlocksCudaOptions.Default);

        Assert.Equal((long)Rows, defaults.NonConvergedEvaluations[Form]);
        Assert.Equal((long)Rows, defaults.NonConvergedEvaluations[Sibling]);
        Assert.All(defaults.Outputs["valid"].AsBooleanVector().ToArray(), flag => Assert.True(flag));
        Assert.Equal((long)Rows, invalid.NonConvergedEvaluations[Form]);
        Assert.All(invalid.Outputs["valid"].AsBooleanVector().ToArray(), flag => Assert.False(flag));
        Assert.Equal(Enumerable.Repeat(-1d, Rows), invalid.Outputs["values"].AsVector().ToArray());
        Assert.Empty(converging.NonConvergedEvaluations);
        Assert.All(converging.Outputs["valid"].AsBooleanVector().ToArray(), flag => Assert.True(flag));
        Assert.Throws<ArgumentOutOfRangeException>(() => expression.EvaluateCoreCLR(inputs, null, new MathBlockDomainOptions { IncompleteBetaMaximumIterations = 0 }, MathBlocksCudaOptions.Default));
    }

    /// <summary>Verifies the fused CUDA kernel, built with the domain options, gives the CoreCLR outputs and counts under each option set.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "LaunchOptions")]
    [MemberData(nameof(OptionSets))]
    public void CUDAFusedKernelEqualsCoreCLRUnderTheDomainOptions(string optionSet)
    {
        ArgumentException.ThrowIfNullOrEmpty(optionSet);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (expression, inputs) = BetaExpression();
        var domain = Options(optionSet);

        var reference = expression.EvaluateCoreCLR(inputs, null, domain, MathBlocksCudaOptions.Default);
        var results = MathBlockFusedTestSupport.RunCudaWithDomain(expression.CudaSource, [expression], [inputs], MathBlocksCudaOptions.Default, domain);

        Assert.Single(results);
        Assert.Equal(reference.InvalidMask, results[0].InvalidMask);
        Assert.Equal(reference.NonConvergedEvaluations, results[0].NonConvergedEvaluations);
        foreach (var (name, value) in reference.Outputs)
            Assert.True(MathBlockDomainWiringTests.Same(value, results[0].Outputs[name]), $"{name} under {optionSet}");
    }
}
