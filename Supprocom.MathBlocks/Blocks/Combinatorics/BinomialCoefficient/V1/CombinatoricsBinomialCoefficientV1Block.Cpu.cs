namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Probability contract.</summary>
public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>combinatorics.binomial-coefficient@1</c> mathematical operation.</summary>
    public static float BinomialCoefficient(int n, int k) => BinomialCoefficientWide(n, k);

    // The coefficient with n in 64 bits, so that the sum of two int32 values does not wrap. After the symmetry step n is
    // at least 2k, so from k = 600 on the coefficient exceeds 1e359 and the loop ends at +Infinity; that value is
    // returned without running the loop. A smaller k that overflows part way stops at the first +Infinity as well.
    internal static float BinomialCoefficientWide(long n, int k)
    {
        if (k < 0 || k > n)
            return 0f;
        k = (int)Math.Min(k, n - k);
        if (k >= 600)
            return float.PositiveInfinity;
        var result = 1f;
        for (var index = 1; index <= k; index++)
        {
            result = result * (float)(n - k + index) / index;
            // Every multiplier and divisor from here on is at least 1, so +Infinity stays +Infinity.
            if (float.IsInfinity(result))
                break;
        }

        if (float.IsPositiveInfinity(result))
            return BinomialCoefficientOrdered(n, k);
        return result;
    }

    /// <summary>Recomputes C(n, k) for <c>0 &lt;= k &lt;= n - k</c> when the product loop of <see cref="BinomialCoefficientWide(long, int)"/> overflowed.</summary>
    /// <remarks>
    /// Each step multiplies by the already divided quotient <c>(n - k + index) / index</c>, so the running value after step <c>i</c> is about
    /// C(n - k + i, i) and never exceeds the final value. The result is positive infinity only when C(n, k) itself exceeds the largest double.
    /// </remarks>
    /// <param name="n">The set size.</param>
    /// <param name="k">The reduced choice count, at most <c>n - k</c>.</param>
    /// <returns>C(n, k), or positive infinity when it is not representable.</returns>
    internal static float BinomialCoefficientOrdered(long n, int k)
    {
        var result = 1f;
        for (var index = 1; index <= k; index++)
            result = result * ((float)(n - k + index) / index);
        return result;
    }
}
