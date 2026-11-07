namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>probability.poisson-cdf@1</c> mathematical operation.</summary>
    public static double PoissonCdf(double rate, int count)
    {
        // The sum of the terms 0..count in index order. A term whose exponent is below -800 is exactly +0.0 (Math.Exp
        // underflows below -745.13), and adding +0.0 leaves the sum unchanged, so those terms are skipped: the exponent
        // rises with the index up to the rate and falls after it. The exponent expression is PoissonPmf's.
        if (rate == 0d)
            return 1d;
        var logRate = Math.Log(rate);
        double Exponent(int index) => -rate + index * logRate - MathBlockProbability.LogGamma(index + 1d);
        var peak = rate < count ? (int)rate : count;
        if (Exponent(peak) < -800d)
            return 0d;
        var first = 0;
        var high = peak;
        while (first < high)
        {
            var middle = first + (high - first) / 2;
            if (Exponent(middle) >= -800d)
                high = middle;
            else
                first = middle + 1;
        }

        var sum = 0d;
        for (var index = first; index <= count; index++)
        {
            var exponent = Exponent(index);
            if (index > rate && exponent < -800d)
                break;
            sum += Math.Exp(exponent);
        }

        return sum;
    }
}
