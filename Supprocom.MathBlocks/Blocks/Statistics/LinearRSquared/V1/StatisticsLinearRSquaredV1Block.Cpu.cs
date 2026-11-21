namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.linear-r-squared@1</c> mathematical operation.</summary>
    public static float LinearRSquared(IReadOnlyList<float> x, IReadOnlyList<float> y)
    {
        var correlation = PearsonCorrelation(x, y);
        return correlation * correlation;
    }
}
