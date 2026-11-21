namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.cumulative-sum@1</c> mathematical operation.</summary>
    public static float[] CumulativeSum(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count];
        var sum = 0f;
        for (var index = 0; index < values.Count; index++)
        {
            sum += values[index];
            result[index] = sum;
        }

        return result;
    }
}
