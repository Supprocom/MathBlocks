namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double PopulationVariance(IReadOnlyList<double> values)
    {
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
