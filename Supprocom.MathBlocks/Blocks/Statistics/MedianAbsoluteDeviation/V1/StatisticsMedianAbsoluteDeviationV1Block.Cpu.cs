namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.median-absolute-deviation@1</c> mathematical operation.</summary>
    public static float MedianAbsoluteDeviation(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var median = MathBlockVectorMath.Median(values);
        var deviations = new float[values.Count];
        for (var index = 0; index < values.Count; index++)
            deviations[index] = Math.Abs(values[index] - median);
        return MathBlockVectorMath.Median(deviations);
    }
}
