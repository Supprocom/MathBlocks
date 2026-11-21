namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>probability.poisson-cdf@1</c> mathematical operation.</summary>
    public static float PoissonCdf(float rate, int count)
    {
        // The sum of the terms 0..count in index order. A term whose exponent is below -104 is exactly +0.0 (Math.Exp
        // underflows below -103.98), and adding +0.0 leaves the sum unchanged, so those terms are skipped: the exponent
        // rises with the index up to the rate and falls after it. The exponent expression is PoissonPmf's.
        if (rate == 0f)
            return 1f;
        var logRate = Math.Log(rate);
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
            // Past the peak the terms only fall, so once one leaves the sum unchanged every later one does too.
            var nextSum = sum + Math.Exp(exponent);
            if (index > rate && nextSum == sum)
                break;
            sum = nextSum;
        }

        return sum;
    }
}
