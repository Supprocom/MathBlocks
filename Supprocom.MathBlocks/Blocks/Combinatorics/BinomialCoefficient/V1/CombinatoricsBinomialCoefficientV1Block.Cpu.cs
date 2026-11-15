namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Probability contract.</summary>
public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>combinatorics.binomial-coefficient@1</c> mathematical operation.</summary>
    public static double BinomialCoefficient(int n, int k) => BinomialCoefficientWide(n, k);

    // The coefficient with n in 64 bits, so that the sum of two int32 values does not wrap. After the symmetry step n is
    // at least 2k, so from k = 600 on the coefficient exceeds 1e359 and the loop ends at +Infinity; that value is
    // returned without running the loop. A smaller k that overflows part way stops at the first +Infinity as well.
    internal static double BinomialCoefficientWide(long n, int k)
    {
        if (k < 0 || k > n)
            return 0d;
        k = (int)Math.Min(k, n - k);
        if (k >= 600)
            return double.PositiveInfinity;
        var result = 1d;
        for (var index = 1; index <= k; index++)
        {
            result = result * (double)(n - k + index) / index;
            // Every factor and divisor from here on is at least 1, so +Infinity stays +Infinity.
            if (double.IsInfinity(result))
                break;
        }

        return result;
    }
}
