namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] ExponentialMovingAverage(IReadOnlyList<double> values, double alpha)
    {
        var result = new double[values.Count];
        result[0] = values[0];
        for (var index = 1; index < values.Count; index++)
            result[index] = alpha * values[index] + (1d - alpha) * result[index - 1];
        return result;
    }
}
