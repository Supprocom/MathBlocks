namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.linear-slope@1</c> mathematical operation.</summary>
    public static double LinearSlope(IReadOnlyList<double> x, IReadOnlyList<double> y)
    {
        // A variance of x that overflows would give a finite zero slope; the result is not finite instead.
        var variance = PopulationVariance(x);
        return Math.IsFinite(variance) ? PopulationCovariance(x, y) / variance : Math.NaN;
    }
}
