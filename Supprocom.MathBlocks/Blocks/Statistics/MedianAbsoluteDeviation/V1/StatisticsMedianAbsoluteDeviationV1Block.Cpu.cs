namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double MedianAbsoluteDeviation(IReadOnlyList<double> values)
    {
        var median = MathBlockVectorMath.Median(values);
        var deviations = new double[values.Count];
        for (var index = 0; index < values.Count; index++)
            deviations[index] = Math.Abs(values[index] - median);
        return MathBlockVectorMath.Median(deviations);
    }
}
