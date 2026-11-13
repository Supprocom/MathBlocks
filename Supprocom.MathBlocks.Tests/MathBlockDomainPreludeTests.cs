using System.Text.RegularExpressions;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains the source-inspection tests of the domain limit functions in the device source and in the generated source.</summary>
public sealed partial class MathBlockDomainPreludeTests
{
    [GeneratedRegex(
        @"static __device__ __forceinline__ (?:int|double|long long) (?<name>mathblocks_limit_\w+)\([^)]*\) \{ return (?<value>[^;]+); \}",
        RegexOptions.CultureInvariant | RegexOptions.ExplicitCapture,
        matchTimeoutMilliseconds: 10_000)]
    private static partial Regex LimitFunction();

    [GeneratedRegex(@"mathblocks_limit_\w+(?=\()", RegexOptions.CultureInvariant, matchTimeoutMilliseconds: 10_000)]
    private static partial Regex LimitCall();

    private static MathBlockDomainOptions Configured() => new()
    {
        MaximumExplicitSubsetSize = 24,
        MaximumStateCount = 8192,
        MaximumGeneratedVectorLength = 2_000_000,
        MaximumSubmodularSetFunctionValues = 8192,
        MaximumShapleyCoalitionValues = 1 << 21,
        MaximumChoquetPlayerCount = 12,
        MaximumMaximalMinorColumns = 22,
        MaximumTotallyNonnegativeSize = 9,
        MaximumMatrixSize = 5000,
        MaximumIterationCount = 20_000,
        IncompleteBetaMaximumIterations = 1024,
        IncompleteBetaTolerance = 1e-10,
        IncompleteBetaNonConvergence = MathBlockNonConvergencePolicy.Invalid,
        JacobiRotationMultiplier = 512,
        JacobiNonConvergence = MathBlockNonConvergencePolicy.Invalid,
        MatrixExponentialTaylorTerms = 12,
        CubeRootNewtonSteps = 5
    };

    // The limit functions defined in the text, by name, with their return expressions.
    private static Dictionary<string, string> LimitFunctions(string text) =>
        LimitFunction().Matches(text).ToDictionary(match => match.Groups["name"].Value, match => match.Groups["value"].Value, StringComparer.Ordinal);

    /// <summary>Verifies a source built for configured domain options defines every limit function once, first, with the configured value.</summary>
    [Fact]
    public void ASourceForConfiguredOptionsReturnsTheConfiguredValueFromEveryLimitFunction()
    {
        var expected = new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["mathblocks_limit_explicit_subset_size"] = "24",
            ["mathblocks_limit_state_count"] = "8192",
            ["mathblocks_limit_generated_vector_length"] = "2000000",
            ["mathblocks_limit_submodular_set_function_values"] = "8192",
            ["mathblocks_limit_shapley_coalition_values"] = "2097152",
            ["mathblocks_limit_choquet_player_count"] = "12",
            ["mathblocks_limit_maximal_minor_columns"] = "22",
            ["mathblocks_limit_totally_nonnegative_size"] = "9",
            ["mathblocks_limit_matrix_size"] = "5000",
            ["mathblocks_limit_iteration_count"] = "20000",
            ["mathblocks_limit_incomplete_beta_maximum_iterations"] = "1024",
            ["mathblocks_limit_incomplete_beta_tolerance"] = "1E-10",
            ["mathblocks_limit_incomplete_beta_policy"] = "1",
            ["mathblocks_limit_jacobi_policy"] = "1",
            ["mathblocks_limit_jacobi_rotation_budget"] = "(long long)512 * size * size",
            ["mathblocks_limit_matrix_exponential_taylor_terms"] = "12",
            ["mathblocks_limit_cube_root_newton_steps"] = "5",
            ["mathblocks_limit_elementwise_source_count"] = "53"
        };

        var source = MathBlockCudaDeviceModule.GetSource(Configured());
        var guard = source.IndexOf("#ifndef MATHBLOCKS_DOMAIN_PRELUDE", StringComparison.Ordinal);
        var define = source.IndexOf("#define MATHBLOCKS_DOMAIN_PRELUDE", StringComparison.Ordinal);

        // The macro and the configured definitions come before the generated source's default block, which the macro skips: one definition of each name.
        Assert.True(define >= 0 && define < guard);
        Assert.Equal(expected, LimitFunctions(source[..guard]));
        Assert.Equal(expected.Count, LimitFunction().Count(source[..guard]));
        Assert.Equal(source + "\n// consumer", MathBlockCudaDeviceModule.ComposeSource("// consumer", Configured()));
        Assert.Equal(MathBlockCudaDeviceModule.GetSourceFingerprint(Configured()), MathBlockCudaDeviceModule.GetSourceFingerprint(Configured()), StringComparer.Ordinal);
        Assert.NotEqual(MathBlockCudaDeviceModule.GetSourceFingerprint(Configured()), MathBlockCudaDeviceModule.SourceFingerprint, StringComparer.Ordinal);
    }

    /// <summary>Verifies the generated source compiles on its own: it defines, under the guard, every limit function the units call, with the default values.</summary>
    [Fact]
    public void TheGeneratedSourceDefinesTheDefaultLimitsOnItsOwn()
    {
        var generated = (string)typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaGeneratedSource", throwOnError: true)!
            .GetField("Source")!.GetRawConstantValue()!;
        var guard = generated.IndexOf("#ifndef MATHBLOCKS_DOMAIN_PRELUDE", StringComparison.Ordinal);
        var end = generated.IndexOf("#endif", guard, StringComparison.Ordinal);
        Assert.True(guard >= 0 && end > guard);
        var defined = LimitFunctions(generated[guard..end]);
        var called = LimitCall().Matches(generated[end..]).Select(match => match.Value).Distinct(StringComparer.Ordinal).ToArray();
        var defaults = MathBlockCudaDeviceModule.GetSource(MathBlockDomainOptions.Default);
        var libraryDefaults = LimitFunctions(defaults[..defaults.IndexOf("#ifndef MATHBLOCKS_DOMAIN_PRELUDE", StringComparison.Ordinal)]);

        Assert.NotEmpty(called);
        Assert.All(called, name => Assert.True(defined.ContainsKey(name), name));
        // The block is what the library's default prelude says, so the generated source and the composed source agree on the defaults.
        Assert.Equal(libraryDefaults.Count, defined.Count);
        foreach (var (name, value) in libraryDefaults)
            Assert.Equal(value, defined[name], StringComparer.Ordinal);
        Assert.Contains("mathblocks_nonconvergence_counts", generated[guard..end], StringComparison.Ordinal);
    }
}
