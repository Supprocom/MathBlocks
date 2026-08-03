namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Standardize(IReadOnlyList<double> values)
    {
        var mean = Mean(values);
        var variance = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            var difference = values[index] - mean;
            variance += difference * difference;
        }

        variance /= values.Count;
        var deviation = Math.Sqrt(variance);
        return Map(values, value => (value - mean) / deviation);
    }
}
