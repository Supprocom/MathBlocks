namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.rolling-standard-deviation@1</c> mathematical operation.</summary>
    public static double[] RollingStandardDeviation(IReadOnlyList<double> values, int width)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new double[values.Count - width + 1];
        for (var start = 0; start < result.Length; start++)
        {
            var mean = 0d;
            for (var index = 0; index < width; index++)
                mean += values[start + index];
            mean /= width;
            var sumSquares = 0d;
            for (var index = 0; index < width; index++)
            {
                var difference = values[start + index] - mean;
                sumSquares += difference * difference;
            }

            result[start] = Math.Sqrt(sumSquares / width);
        }

        return result;
    }
}
