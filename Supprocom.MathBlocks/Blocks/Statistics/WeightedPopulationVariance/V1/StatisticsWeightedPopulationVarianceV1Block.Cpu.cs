namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.weighted-population-variance@1</c> mathematical operation.</summary>
    public static float WeightedPopulationVariance(IReadOnlyList<float> values, IReadOnlyList<float> weights)
    {
        ArgumentNullException.ThrowIfNull(values);
        ArgumentNullException.ThrowIfNull(weights);
        var mean = WeightedMean(values, weights);
        var numerator = 0f;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            numerator += weights[index] * difference * difference;
        }

        return numerator / MathBlockVectorMath.Sum(weights);
    }
}
