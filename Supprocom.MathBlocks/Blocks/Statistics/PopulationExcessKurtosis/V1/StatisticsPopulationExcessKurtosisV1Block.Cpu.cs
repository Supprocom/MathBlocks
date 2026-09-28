namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.population-excess-kurtosis@1</c> mathematical operation.</summary>
    public static double PopulationExcessKurtosis(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var mean = MathBlockVectorMath.Mean(values);
        var second = 0d;
        var fourth = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            var square = difference * difference;
            second += square;
            fourth += square * square;
        }

        second /= values.Count;
        fourth /= values.Count;
        return fourth / (second * second) - 3d;
    }
}
