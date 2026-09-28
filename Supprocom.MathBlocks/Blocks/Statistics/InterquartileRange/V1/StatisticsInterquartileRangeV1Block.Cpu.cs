namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.interquartile-range@1</c> mathematical operation.</summary>
    public static double InterquartileRange(IReadOnlyList<double> values) => MathBlockVectorMath.Quantile(values, 0.75d) - MathBlockVectorMath.Quantile(values, 0.25d);
}
