
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double GiniCoefficient(IReadOnlyList<double> values)
    {
        var sum = 0d;
        for (var left = 0; left < values.Count; left++)
            for (var right = 0; right < values.Count; right++)
                sum += Math.Abs(values[left] - values[right]);
        return sum / (2d * values.Count * MathBlockVectorMath.Sum(values));
    }
}
