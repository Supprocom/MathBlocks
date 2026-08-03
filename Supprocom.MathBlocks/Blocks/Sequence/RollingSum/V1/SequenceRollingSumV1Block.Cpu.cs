namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] RollingSum(IReadOnlyList<double> values, int width)
    {
        var result = new double[values.Count - width + 1];
        var sum = 0d;
        for (var index = 0; index < width; index++)
            sum += values[index];
        result[0] = sum;
        for (var index = width; index < values.Count; index++)
        {
            sum += values[index] - values[index - width];
            result[index - width + 1] = sum;
        }

        return result;
    }
}
