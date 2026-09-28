
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>inequality.gini-coefficient@1</c> mathematical operation.</summary>
    public static double GiniCoefficient(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var sum = 0d;
        for (var left = 0; left < values.Count; left++)
            for (var right = 0; right < values.Count; right++)
                sum += Math.Abs(values[left] - values[right]);
        return sum / (2d * values.Count * MathBlockVectorMath.Sum(values));
    }
}
