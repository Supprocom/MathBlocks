using System.Globalization;
using System.Numerics;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the CoreCLR tests of the binomial coefficient where the product loop overflows although C(n, k) fits in a double: the ordered fallback gives the value, every
/// pair the loop handled keeps its bits, and a pair whose value exceeds the largest double stays positive infinity.
/// </summary>
public sealed class MathBlockBinomialOverflowTests
{
    // Pairs the product loop turned into +infinity although C(n, k) is below the largest double: the middle of the rows near 1023, and large n with k around 67.
    private static readonly (int N, int K)[] FixedPairs =
    [
        (1023, 511), (1023, 512), (1023, 500), (1022, 511), (1021, 496), (1024, 477), (1115, 372), (1000000, 67), (1000000, 999933)
    ];

    // Pairs whose value exceeds the largest double.
    private static readonly (int N, int K)[] OverflowPairs = [(1000000, 68), (1500, 700), (5000, 600), (1030, 515), (2147483647, 600)];

    // The product loop as it was before the fallback, copied here as the reference for the pairs that never overflowed.
    private static double ReferenceLoop(int n, int k)
    {
        if (k < 0 || k > n)
            return 0d;
        k = Math.Min(k, n - k);
        var result = 1d;
        for (var index = 1; index <= k; index++)
            result = result * (n - k + index) / index;
        return result;
    }

    // C(n, k) exactly: after step i the running value is C(n - k + i, i), so each division is exact.
    private static BigInteger Exact(int n, int k)
    {
        k = Math.Min(k, n - k);
        var result = BigInteger.One;
        for (var index = 1; index <= k; index++)
            result = result * (n - k + index) / index;
        return result;
    }

    private static string Describe(int n, int k, double value, string what) =>
        string.Create(CultureInfo.InvariantCulture, $"C({n}, {k}) = {value:R} {what}.");

    private static readonly BigInteger LargestDouble = new(double.MaxValue);

    /// <summary>Verifies the fixed pairs give a finite value within 2e-14 of the exact coefficient, about 90 ulps, which is the error of the loop itself at k near 500.</summary>
    [Fact]
    public void PairsWhoseProductOverflowedGiveTheFiniteCoefficient()
    {
        for (var pair = 0; pair < FixedPairs.Length; pair++)
        {
            var (n, k) = FixedPairs[pair];
            var value = MathBlockProbability.BinomialCoefficient(n, k);
            Assert.True(double.IsFinite(value), Describe(n, k, value, "is not finite"));
            var exact = Exact(n, k);
            Assert.True(exact < LargestDouble, Describe(n, k, value, "does not fit in a double"));
            var relative = (double)BigInteger.Abs(new BigInteger(value) - exact) / (double)exact;
            Assert.True(relative <= 2e-14, Describe(n, k, value, "is off by a relative " + relative.ToString("E2", CultureInfo.InvariantCulture)));
        }
    }

    /// <summary>Verifies pairs whose coefficient is above the largest double stay positive infinity.</summary>
    [Fact]
    public void PairsWhoseCoefficientExceedsTheLargestDoubleStayPositiveInfinity()
    {
        for (var pair = 0; pair < OverflowPairs.Length; pair++)
        {
            var (n, k) = OverflowPairs[pair];
            Assert.True(Exact(n, k) > LargestDouble, Describe(n, k, 0d, "fits in a double"));
            Assert.True(double.IsPositiveInfinity(MathBlockProbability.BinomialCoefficient(n, k)), Describe(n, k, 0d, "is not +infinity"));
        }
    }

    /// <summary>Verifies every pair with 0 &lt;= k &lt;= n &lt;= 1023 and the sampled larger pairs the loop did not overflow on keep the bits of the loop.</summary>
    [Fact]
    public void PairsTheLoopHandledKeepItsBits()
    {
        var compared = 0;
        var fixedPairs = 0;
        for (var n = 0; n <= 1023; n++)
        {
            for (var k = 0; k <= n; k++)
                Compare(n, k, ref compared, ref fixedPairs);
        }

        for (var n = 1024; n <= 4096; n += 7)
        {
            for (var k = 0; k < 130; k++)
            {
                Compare(n, k, ref compared, ref fixedPairs);
                Compare(n, n - k, ref compared, ref fixedPairs);
            }
        }

        int[] large = [10_000, 100_000, 1_000_000, 10_000_000, 100_000_000, int.MaxValue];
        for (var index = 0; index < large.Length; index++)
        {
            for (var k = 0; k < 70; k++)
            {
                Compare(large[index], k, ref compared, ref fixedPairs);
                Compare(large[index], large[index] - k, ref compared, ref fixedPairs);
            }
        }

        Assert.True(compared > 500_000);
        Assert.True(fixedPairs > 0);
    }

    private static void Compare(int n, int k, ref int compared, ref int fixedPairs)
    {
        var reference = ReferenceLoop(n, k);
        var value = MathBlockProbability.BinomialCoefficient(n, k);
        compared++;
        if (double.IsPositiveInfinity(reference))
        {
            if (!(value >= 0d))
                Assert.Fail(Describe(n, k, value, "is negative or not a number"));
            if (double.IsFinite(value))
                fixedPairs++;
            return;
        }

        if (BitConverter.DoubleToInt64Bits(reference) != BitConverter.DoubleToInt64Bits(value))
            Assert.Fail(Describe(n, k, value, "differs from the loop's " + reference.ToString("R", CultureInfo.InvariantCulture)));
    }

    /// <summary>Verifies the pairs outside 0 &lt;= k &lt;= n give 0.</summary>
    [Fact]
    public void PairsOutsideTheDomainGiveZero()
    {
        Assert.Equal(0d, MathBlockProbability.BinomialCoefficient(10, -1));
        Assert.Equal(0d, MathBlockProbability.BinomialCoefficient(10, 11));
        Assert.Equal(1d, MathBlockProbability.BinomialCoefficient(1_000_000, 0));
    }
}
