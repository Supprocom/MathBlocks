
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static double[] ReflectedCumulativeSum(IReadOnlyList<double> increments)
    {
        var result = new double[increments.Count];
        var cumulative = 0d;
        var minimum = 0d;
        for (var index = 0; index < increments.Count; index++)
        {
            cumulative += increments[index];
            minimum = Math.Min(minimum, cumulative);
            result[index] = cumulative - minimum;
        }

        return result;
    }
}
