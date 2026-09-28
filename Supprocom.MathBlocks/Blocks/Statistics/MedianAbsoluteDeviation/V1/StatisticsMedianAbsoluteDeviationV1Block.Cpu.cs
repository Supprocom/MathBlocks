namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.median-absolute-deviation@1</c> mathematical operation.</summary>
    public static double MedianAbsoluteDeviation(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var median = MathBlockVectorMath.Median(values);
        var deviations = new double[values.Count];
        for (var index = 0; index < values.Count; index++)
            deviations[index] = Math.Abs(values[index] - median);
        return MathBlockVectorMath.Median(deviations);
    }
}
