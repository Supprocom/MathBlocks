using System.Diagnostics;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>probability.poisson-cdf@1</c> operation contract.</summary>
public sealed class ProbabilityPoissonCdfV1BlockTests
{
    /// <summary>Checks the <c>probability.poisson-cdf@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("probability.poisson-cdf@1");

    /// <summary>
    /// Checks that long counts finish quickly, with the bits the released 0.6.0 summed over every term. The terms the
    /// sum skips are exactly 0.0 (their exponent is below -800), so the sum is unchanged.
    /// </summary>
    [Theory]
    [InlineData(110d, 4194304, 0x3FF0000000000168L)]
    [InlineData(1d, 100000, 0x3FF0000000000000L)]
    [InlineData(110d, 8192, 0x3FF0000000000168L)]
    [InlineData(110d, 0, 0x3603BF2CF6722E46L)]
    [InlineData(110d, 109, 0x3FDF3040DFBCB7F4L)]
    [InlineData(110d, 110, 0x3FE0CF7EC50DCF83L)]
    [InlineData(110d, 111, 0x3FE2040EFDCBD349L)]
    [InlineData(0.5d, 1, 0x3FED1D0C7AA76114L)]
    [InlineData(1e6d, 999999, 0x3FDFFDD23D2DBB72L)]
    [InlineData(1e6d, 1000000, 0x3FE0022DC313C605L)]
    [InlineData(1e6d, 100000, 0L)]
    [InlineData(1e300d, 4194304, 0L)]
    [InlineData(0d, 4194304, 0x3FF0000000000000L)]
    public void LongCountsMatchTheSumOverEveryTerm(double rate, int count, long expectedBits)
    {
        var watch = Stopwatch.StartNew();
        var actual = MathBlockAdvanced.PoissonCdf(rate, count);
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(1), $"PoissonCdf({rate}, {count}) took {watch.Elapsed.TotalMilliseconds} ms.");
        Assert.Equal(expectedBits, BitConverter.DoubleToInt64Bits(actual));
    }
}
