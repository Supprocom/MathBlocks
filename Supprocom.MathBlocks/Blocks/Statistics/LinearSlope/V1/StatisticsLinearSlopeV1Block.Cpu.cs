namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.linear-slope@1</c> mathematical operation.</summary>
    public static double LinearSlope(IReadOnlyList<double> x, IReadOnlyList<double> y) => PopulationCovariance(x, y) / PopulationVariance(x);
}
