namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double WeightedPopulationVariance(IReadOnlyList<double> values, IReadOnlyList<double> weights)
    {
        var mean = WeightedMean(values, weights);
        var numerator = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            numerator += weights[index] * difference * difference;
        }

        return numerator / MathBlockVectorMath.Sum(weights);
    }
}
