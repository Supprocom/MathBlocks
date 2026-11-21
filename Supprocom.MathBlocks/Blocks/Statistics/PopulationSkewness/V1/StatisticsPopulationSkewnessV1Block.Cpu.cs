namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.population-skewness@1</c> mathematical operation.</summary>
    public static float PopulationSkewness(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var mean = MathBlockVectorMath.Mean(values);
        var second = 0f;
        var third = 0f;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            var square = difference * difference;
            second += square;
            third += square * difference;
        }

        second /= values.Count;
        third /= values.Count;
        return third / Math.Pow(second, 1.5f);
    }
}
