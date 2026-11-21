
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.reflected-cumulative-sum@1</c> mathematical operation.</summary>
    public static float[] ReflectedCumulativeSum(IReadOnlyList<float> increments)
    {
        ArgumentNullException.ThrowIfNull(increments);
        var result = new float[increments.Count];
        var cumulative = 0f;
        var minimum = 0f;
        for (var index = 0; index < increments.Count; index++)
        {
            cumulative += increments[index];
            minimum = Math.Min(minimum, cumulative);
            result[index] = cumulative - minimum;
        }

        return result;
    }
}
