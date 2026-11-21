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
    /// Checks that long counts finish quickly, with the bits of the sum over every term. The terms the sum skips are
    /// exactly 0.0 (their exponent is below -104), so the sum is unchanged.
    /// </summary>
    [Theory]
    [InlineData(110f, 4194304, 0x3F80000A)]
    [InlineData(1f, 100000, 0x3F7FFFF8)]
    [InlineData(110f, 8192, 0x3F80000A)]
    [InlineData(110f, 0, 0)]
    [InlineData(110f, 109, 0x3EF981BC)]
    [InlineData(110f, 110, 0x3F067BC2)]
    [InlineData(110f, 111, 0x3F102067)]
    [InlineData(0.5f, 1, 0x3F68E85C)]
    [InlineData(1e6f, 100000, 0)]
    [InlineData(3.16e37f, 4194304, 0)]
    [InlineData(0f, 4194304, 0x3F800000)]
    public void LongCountsMatchTheSumOverEveryTerm(float rate, int count, int expectedBits)
    {
        var watch = Stopwatch.StartNew();
        var actual = MathBlockAdvanced.PoissonCdf(rate, count);
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(1), $"PoissonCdf({rate}, {count}) took {watch.Elapsed.TotalMilliseconds} ms.");
        Assert.Equal(expectedBits, BitConverter.SingleToInt32Bits(actual));
    }

    /// <summary>
    /// Checks that a count at the peak of a rate of one million finishes quickly with a finite sum. The exponent of a term there is the
    /// difference of numbers near 1.4e7, which a single-precision value holds to about one unit, so the sum's value is not pinned.
    /// </summary>
    [Theory]
    [InlineData(1e6f, 999999)]
    [InlineData(1e6f, 1000000)]
    public void CountsAtThePeakOfAVeryLargeRateFinishQuickly(float rate, int count)
    {
        var watch = Stopwatch.StartNew();
        var actual = MathBlockAdvanced.PoissonCdf(rate, count);
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(1), $"PoissonCdf({rate}, {count}) took {watch.Elapsed.TotalMilliseconds} ms.");
        Assert.True(float.IsFinite(actual) && actual >= 0f);
    }

    /// <summary>
    /// Checks that stopping once a term past the peak leaves the sum unchanged gives the bits of the sum over every term down to the
    /// exponent cut at -104, on rates from 0 to 1e5 including the values just below and above integers, with counts below, at and above the peak. Above 1e5 the
    /// rounding of a term's exponent is larger than the step between neighbouring terms, so the terms no longer fall steadily past the peak.
    /// </summary>
    [Fact]
    [Trait("Category", "CostGuard")]
    public void StoppingOnceTheSumIsUnchangedKeepsTheBits()
    {
        float[] rates = [1.03e-37f, 1e-10f, 0.001f, 0.5f, 1f, 2.5f, 10f, 100.5f, 1e3f, 1e5f, float.BitDecrement(1e3f), float.BitIncrement(1e3f), float.BitDecrement(1e5f), float.BitIncrement(1e5f)];
        var mismatches = new List<string>();
        var compared = 0;
        for (var index = 0; index < rates.Length; index++)
        {
            var rate = rates[index];
            var floor = (int)MathF.Floor(rate);
            foreach (var count in new[] { 0, 1, Math.Max(0, floor - 1), floor, floor + 1, (int)(rate * 1.5f) + 5, (int)Math.Min(int.MaxValue, 2f * floor + 10), (int)Math.Min(int.MaxValue, 10f * floor + 1000) })
            {
                compared++;
                if (BitConverter.SingleToInt32Bits(PoissonCdfOverEveryTerm(rate, count)) != BitConverter.SingleToInt32Bits(MathBlockAdvanced.PoissonCdf(rate, count)))
                    mismatches.Add($"({rate:R}, {count})");
            }
        }

        Assert.True(mismatches.Count == 0, string.Join(", ", mismatches.Take(20)));
        Assert.True(compared > 100);
    }

    // The sum of the terms in index order with only the exponent cut at -104, as PoissonCdf summed them before it stopped on an unchanged sum.
    private static float PoissonCdfOverEveryTerm(float rate, int count)
    {
        var logRate = MathBlockScalar.NaturalLogarithm(rate);
        float Exponent(int index) => -rate + index * logRate - MathBlockProbability.LogGamma(index + 1f);
        var peak = rate < count ? (int)rate : count;
        if (Exponent(peak) < -104f)
            return 0f;
        var first = 0;
        var high = peak;
        while (first < high)
        {
            var middle = first + (high - first) / 2;
            if (Exponent(middle) >= -104f)
                high = middle;
            else
                first = middle + 1;
        }

        var sum = 0f;
        for (var index = first; index <= count; index++)
        {
            var exponent = Exponent(index);
            if (index > rate && exponent < -104f)
                break;
            sum += MathBlockScalar.Exponential(exponent);
        }

        return sum;
    }
}
