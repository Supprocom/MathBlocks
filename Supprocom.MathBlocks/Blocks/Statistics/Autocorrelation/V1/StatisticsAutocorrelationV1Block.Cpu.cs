namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double Autocorrelation(IReadOnlyList<double> values, int lag)
    {
        var left = MathBlockVectorMath.Slice(values, 0, values.Count - lag);
        var right = MathBlockVectorMath.Slice(values, lag, values.Count - lag);
        return PearsonCorrelation(left, right);
    }
}
