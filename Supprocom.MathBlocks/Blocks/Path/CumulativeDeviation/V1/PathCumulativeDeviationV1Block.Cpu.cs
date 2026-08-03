
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static double[] CumulativeDeviation(IReadOnlyList<double> values, double reference)
    {
        var result = new double[values.Count];
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            sum += values[index] - reference;
            result[index] = sum;
        }

        return result;
    }
}
