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
        return result;
    }
}
