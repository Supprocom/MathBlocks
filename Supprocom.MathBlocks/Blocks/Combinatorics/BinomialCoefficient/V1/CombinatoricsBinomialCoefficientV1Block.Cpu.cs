namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Probability contract.</summary>
public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>combinatorics.binomial-coefficient@1</c> mathematical operation.</summary>
    public static double BinomialCoefficient(int n, int k)
    {
        if (k < 0 || k > n)
            return 0d;
        k = Math.Min(k, n - k);
        var result = 1d;
        for (var index = 1; index <= k; index++)
            result = result * (n - k + index) / index;
        if (double.IsPositiveInfinity(result))
            return BinomialCoefficientOrdered(n, k);
        return result;
    }

    /// <summary>Recomputes C(n, k) for <c>0 &lt;= k &lt;= n - k</c> when the product loop of <see cref="BinomialCoefficient(int, int)"/> overflowed.</summary>
    /// <remarks>
    /// Each step multiplies by the already divided factor <c>(n - k + index) / index</c>, so the running value after step <c>i</c> is about
    /// C(n - k + i, i) and never exceeds the final value. The result is positive infinity only when C(n, k) itself exceeds the largest double.
    /// </remarks>
    /// <param name="n">The set size.</param>
    /// <param name="k">The reduced choice count, at most <c>n - k</c>.</param>
    /// <returns>C(n, k), or positive infinity when it is not representable.</returns>
    internal static double BinomialCoefficientOrdered(int n, int k)
    {
        var result = 1d;
        for (var index = 1; index <= k; index++)
            result = result * ((double)(n - k + index) / index);
        return result;
    }
}
