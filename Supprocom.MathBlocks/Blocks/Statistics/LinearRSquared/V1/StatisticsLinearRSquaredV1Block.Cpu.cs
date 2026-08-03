namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double LinearRSquared(IReadOnlyList<double> x, IReadOnlyList<double> y)
    {
        var correlation = PearsonCorrelation(x, y);
        return correlation * correlation;
    }
}
