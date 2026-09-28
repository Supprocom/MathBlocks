namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.population-variance@1</c> mathematical operation.</summary>
    public static double PopulationVariance(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var mean = MathBlockVectorMath.Mean(values);
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            sum += difference * difference;
        }

        return sum / values.Count;
    }
}
