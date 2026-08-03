namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] RollingQuantile(IReadOnlyList<double> values, int width, double probability)
    {
        var result = new double[values.Count - width + 1];
        var window = new double[width];
        for (var start = 0; start < result.Length; start++)
        {
            for (var index = 0; index < width; index++)
                window[index] = values[start + index];
            result[start] = Quantile(window, probability);
        }

        return result;
    }
}
