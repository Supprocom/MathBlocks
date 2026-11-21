using System.Globalization;
using System.Numerics;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the CoreCLR tests of the binomial coefficient where the product loop overflows although C(n, k) fits in a double: the ordered fallback gives the value, every
/// pair the loop handled keeps its bits, and a pair whose value exceeds the largest double stays positive infinity.
/// </summary>
public sealed class MathBlockBinomialOverflowTests
{
    // Pairs the product loop turned into +infinity although C(n, k) is below the largest single: the middle of the rows near 130, and large n with k around 7.
    private static readonly (int N, int K)[] FixedPairs =
    [
        (130, 65), (131, 65), (131, 66), (129, 64), (128, 64), (127, 63), (1000000, 7), (1000000, 999993)
    ];

    // Pairs whose value exceeds the largest single.
    private static readonly (int N, int K)[] OverflowPairs = [(1000000, 8), (200, 100), (500, 60), (132, 66), (2147483647, 600)];

    // The product loop as it was before the fallback, copied here as the reference for the pairs that never overflowed.
    private static float ReferenceLoop(int n, int k)
    {
        if (k < 0 || k > n)
            return 0f;
        k = Math.Min(k, n - k);
        var result = 1f;
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

    private static string Describe(int n, int k, float value, string what) =>
        string.Create(CultureInfo.InvariantCulture, $"C({n}, {k}) = {value:R} {what}.");

    private static readonly BigInteger LargestDouble = new(float.MaxValue);

    /// <summary>Verifies the fixed pairs give a finite value within 2e-6 of the exact coefficient, about 17 ulps, which bounds the error of the loop itself at k near 65.</summary>
    [Fact]
    public void PairsWhoseProductOverflowedGiveTheFiniteCoefficient()
    {
        for (var pair = 0; pair < FixedPairs.Length; pair++)
        {
            var (n, k) = FixedPairs[pair];
            var value = MathBlockProbability.BinomialCoefficient(n, k);
            Assert.True(float.IsFinite(value), Describe(n, k, value, "is not finite"));
            var exact = Exact(n, k);
            Assert.True(exact < LargestDouble, Describe(n, k, value, "does not fit in a double"));
            var relative = (float)BigInteger.Abs(new BigInteger(value) - exact) / (float)exact;
            Assert.True(relative <= 2e-6f, Describe(n, k, value, "is off by a relative " + relative.ToString("E2", CultureInfo.InvariantCulture)));
        }
    }

    /// <summary>Verifies pairs whose coefficient is above the largest double stay positive infinity.</summary>
    [Fact]
    public void PairsWhoseCoefficientExceedsTheLargestDoubleStayPositiveInfinity()
    {
        for (var pair = 0; pair < OverflowPairs.Length; pair++)
        {
            var (n, k) = OverflowPairs[pair];
            Assert.True(Exact(n, k) > LargestDouble, Describe(n, k, 0f, "fits in a double"));
            Assert.True(float.IsPositiveInfinity(MathBlockProbability.BinomialCoefficient(n, k)), Describe(n, k, 0f, "is not +infinity"));
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
        if (float.IsPositiveInfinity(reference))
        {
            if (!(value >= 0f))
                Assert.Fail(Describe(n, k, value, "is negative or not a number"));
            if (float.IsFinite(value))
                fixedPairs++;
            return;
        }

        if (BitConverter.SingleToInt32Bits(reference) != BitConverter.SingleToInt32Bits(value))
            Assert.Fail(Describe(n, k, value, "differs from the loop's " + reference.ToString("R", CultureInfo.InvariantCulture)));
    }

    /// <summary>Verifies the pairs outside 0 &lt;= k &lt;= n give 0.</summary>
    [Fact]
    public void PairsOutsideTheDomainGiveZero()
    {
        Assert.Equal(0f, MathBlockProbability.BinomialCoefficient(10, -1));
        Assert.Equal(0f, MathBlockProbability.BinomialCoefficient(10, 11));
        Assert.Equal(1f, MathBlockProbability.BinomialCoefficient(1_000_000, 0));
    }
}
