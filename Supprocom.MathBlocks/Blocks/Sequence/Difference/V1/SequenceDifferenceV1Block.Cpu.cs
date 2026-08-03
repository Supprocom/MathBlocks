namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] Difference(IReadOnlyList<double> values, int lag = 1)
    {
        var result = new double[values.Count - lag];
        for (var index = lag; index < values.Count; index++)
            result[index - lag] = values[index] - values[index - lag];
        return result;
    }
}
