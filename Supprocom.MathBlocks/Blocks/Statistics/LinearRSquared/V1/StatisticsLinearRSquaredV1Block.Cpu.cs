namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.linear-r-squared@1</c> mathematical operation.</summary>
    public static double LinearRSquared(IReadOnlyList<double> x, IReadOnlyList<double> y)
    {
        var correlation = PearsonCorrelation(x, y);
        return correlation * correlation;
    }
}
