using System.Globalization;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains tests for the load-time validation of <see cref="MathBlockDomainOptions"/>.</summary>
public sealed class MathBlockDomainOptionsTests
{
    private const int MaximumVectorLength = 268_435_455;
    private const int MaximumSquareSize = 16_383;

    private static readonly Dictionary<string, Func<int, MathBlockDomainOptions>> Factories = new(StringComparer.Ordinal)
    {
        [nameof(MathBlockDomainOptions.MaximumExplicitSubsetSize)] = v => new() { MaximumExplicitSubsetSize = v },
        [nameof(MathBlockDomainOptions.MaximumStateCount)] = v => new() { MaximumStateCount = v },
        [nameof(MathBlockDomainOptions.MaximumGeneratedVectorLength)] = v => new() { MaximumGeneratedVectorLength = v },
        [nameof(MathBlockDomainOptions.MaximumSubmodularSetFunctionValues)] = v => new() { MaximumSubmodularSetFunctionValues = v },
        [nameof(MathBlockDomainOptions.MaximumShapleyCoalitionValues)] = v => new() { MaximumShapleyCoalitionValues = v },
        [nameof(MathBlockDomainOptions.MaximumChoquetPlayerCount)] = v => new() { MaximumChoquetPlayerCount = v },
        [nameof(MathBlockDomainOptions.MaximumMaximalMinorColumns)] = v => new() { MaximumMaximalMinorColumns = v },
        [nameof(MathBlockDomainOptions.MaximumTotallyNonnegativeSize)] = v => new() { MaximumTotallyNonnegativeSize = v },
        [nameof(MathBlockDomainOptions.MaximumMatrixSize)] = v => new() { MaximumMatrixSize = v },
        [nameof(MathBlockDomainOptions.MaximumIterationCount)] = v => new() { MaximumIterationCount = v },
        [nameof(MathBlockDomainOptions.IncompleteBetaMaximumIterations)] = v => new() { IncompleteBetaMaximumIterations = v },
        [nameof(MathBlockDomainOptions.JacobiRotationFactor)] = v => new() { JacobiRotationFactor = v }
    };

    /// <summary>Verifies every default is the literal earlier versions hard-coded.</summary>
    [Fact]
    public void DefaultsAreTheEarlierLiterals()
    {
        var options = MathBlockDomainOptions.Default;

        Assert.Equal(20, options.MaximumExplicitSubsetSize);
        Assert.Equal(4_096, options.MaximumStateCount);
        Assert.Equal(1_000_000, options.MaximumGeneratedVectorLength);
        Assert.Equal(1 << 12, options.MaximumSubmodularSetFunctionValues);
        Assert.Equal(1 << 20, options.MaximumShapleyCoalitionValues);
        Assert.Equal(30, options.MaximumChoquetPlayerCount);
        Assert.Equal(20, options.MaximumMaximalMinorColumns);
        Assert.Equal(8, options.MaximumTotallyNonnegativeSize);
        Assert.Equal(4_096, options.MaximumMatrixSize);
        Assert.Equal(10_000, options.MaximumIterationCount);
        Assert.Equal(256, options.IncompleteBetaMaximumIterations);
        Assert.Equal(3e-14, options.IncompleteBetaTolerance);
        Assert.Equal(MathBlockNonConvergencePolicy.Estimate, options.IncompleteBetaNonConvergence);
        Assert.Equal(64, options.JacobiRotationFactor);
        Assert.Equal(MathBlockNonConvergencePolicy.Estimate, options.JacobiNonConvergence);
        Assert.NotEmpty(MathBlockLimits.Resolve(domain: options));
    }

    /// <summary>Verifies the minimum and the maximum load and the values beside them throw naming the option.</summary>
    [Theory]
    [InlineData(nameof(MathBlockDomainOptions.MaximumExplicitSubsetSize), 1, 26)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumStateCount), 1, MaximumSquareSize)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumGeneratedVectorLength), 1, MaximumVectorLength)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumSubmodularSetFunctionValues), 1, 1 << 30)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumShapleyCoalitionValues), 1, 1 << 30)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumChoquetPlayerCount), 1, 30)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumMaximalMinorColumns), 1, 30)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumTotallyNonnegativeSize), 1, 30)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumMatrixSize), 1, MaximumSquareSize)]
    [InlineData(nameof(MathBlockDomainOptions.MaximumIterationCount), 1, int.MaxValue)]
    [InlineData(nameof(MathBlockDomainOptions.IncompleteBetaMaximumIterations), 1, int.MaxValue - 1)]
    [InlineData(nameof(MathBlockDomainOptions.JacobiRotationFactor), 1, int.MaxValue)]
    public void RangesAreLoadTimeErrorsNamingTheOption(string name, int minimum, int maximum)
    {
        var create = Factories[name];
        Assert.NotEmpty(MathBlockLimits.Resolve(domain: create(minimum)));
        Assert.NotEmpty(MathBlockLimits.Resolve(domain: create(maximum)));

        var below = Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(domain: create(minimum - 1)));
        Assert.Equal(name, below.ParamName);
        if (maximum < int.MaxValue)
        {
            var above = Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(domain: create(maximum + 1)));
            Assert.Equal(name, above.ParamName);
            Assert.Contains(maximum.ToString("N0", CultureInfo.InvariantCulture), above.Message, StringComparison.Ordinal);
        }
    }

    /// <summary>Verifies the tolerance and the policies reject values outside their range.</summary>
    [Fact]
    public void ToleranceAndPoliciesRejectValuesOutsideTheirRange()
    {
        Assert.NotEmpty(MathBlockLimits.Resolve(domain: new MathBlockDomainOptions { IncompleteBetaTolerance = 0d }));
        Assert.NotEmpty(MathBlockLimits.Resolve(domain: new MathBlockDomainOptions { IncompleteBetaTolerance = 1d }));
        foreach (var tolerance in new[] { -1e-300, 1.0000001d, double.NaN, double.PositiveInfinity })
        {
            var options = new MathBlockDomainOptions { IncompleteBetaTolerance = tolerance };
            Assert.Equal(
                nameof(MathBlockDomainOptions.IncompleteBetaTolerance),
                Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(domain: options)).ParamName);
        }

        Assert.NotEmpty(MathBlockLimits.Resolve(domain: new MathBlockDomainOptions
        {
            IncompleteBetaNonConvergence = MathBlockNonConvergencePolicy.Invalid,
            JacobiNonConvergence = MathBlockNonConvergencePolicy.Invalid
        }));
        var beta = new MathBlockDomainOptions { IncompleteBetaNonConvergence = (MathBlockNonConvergencePolicy)7 };
        var jacobi = new MathBlockDomainOptions { JacobiNonConvergence = (MathBlockNonConvergencePolicy)(-1) };
        Assert.Equal(
            nameof(MathBlockDomainOptions.IncompleteBetaNonConvergence),
            Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(domain: beta)).ParamName);
        Assert.Equal(
            nameof(MathBlockDomainOptions.JacobiNonConvergence),
            Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(domain: jacobi)).ParamName);
    }
}
