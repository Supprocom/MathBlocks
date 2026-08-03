namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double InterquartileRange(IReadOnlyList<double> values) => MathBlockVectorMath.Quantile(values, 0.75d) - MathBlockVectorMath.Quantile(values, 0.25d);
}
