
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>inequality.gini-coefficient@1</c> mathematical operation.</summary>
    public static float GiniCoefficient(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var sum = 0f;
        for (var left = 0; left < values.Count; left++)
            for (var right = 0; right < values.Count; right++)
                sum += Math.Abs(values[left] - values[right]);
        return sum / (2f * values.Count * MathBlockVectorMath.Sum(values));
    }
}
