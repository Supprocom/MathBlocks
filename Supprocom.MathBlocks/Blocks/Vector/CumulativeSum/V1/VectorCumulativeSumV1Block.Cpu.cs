namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double[] CumulativeSum(IReadOnlyList<double> values)
    {
        var result = new double[values.Count];
        var sum = 0d;
        for (var index = 0; index < values.Count; index++)
        {
            sum += values[index];
            result[index] = sum;
        }

        return result;
    }
}
