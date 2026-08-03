namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double PopulationSkewness(IReadOnlyList<double> values)
    {
        var mean = MathBlockVectorMath.Mean(values);
        var second = 0d;
        var third = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            var square = difference * difference;
            second += square;
            third += square * difference;
        }

        second /= values.Count;
        third /= values.Count;
        return third / Math.Pow(second, 1.5d);
    }
}
