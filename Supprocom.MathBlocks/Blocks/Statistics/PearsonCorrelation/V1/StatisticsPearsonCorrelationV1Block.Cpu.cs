namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.pearson-correlation@1</c> mathematical operation.</summary>
    public static double PearsonCorrelation(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        // A variance or a standard-deviation product that overflows would divide the covariance by an infinity and give a
        // finite zero; the result is then not finite (invalid), as for any overflow in an intermediate.
        var leftVariance = PopulationVariance(left);
        var rightVariance = PopulationVariance(right);
        if (!Math.IsFinite(leftVariance) || !Math.IsFinite(rightVariance))
            return Math.NaN;
        var denominator = Math.Sqrt(leftVariance) * Math.Sqrt(rightVariance);
        return Math.IsFinite(denominator) ? PopulationCovariance(left, right) / denominator : Math.NaN;
    }
}
