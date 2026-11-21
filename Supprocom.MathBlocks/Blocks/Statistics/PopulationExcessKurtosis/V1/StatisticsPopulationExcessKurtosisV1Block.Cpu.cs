namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.population-excess-kurtosis@1</c> mathematical operation.</summary>
    public static float PopulationExcessKurtosis(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var mean = MathBlockVectorMath.Mean(values);
        var second = 0f;
        var fourth = 0f;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            var square = difference * difference;
            second += square;
            fourth += square * square;
        }

        second /= values.Count;
        fourth /= values.Count;
        return fourth / (second * second) - 3f;
    }
}
