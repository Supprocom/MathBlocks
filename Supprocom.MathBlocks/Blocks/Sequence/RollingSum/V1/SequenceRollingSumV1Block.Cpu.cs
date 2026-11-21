namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.rolling-sum@1</c> mathematical operation.</summary>
    public static float[] RollingSum(IReadOnlyList<float> values, int width)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count - width + 1];
        var sum = 0f;
        for (var index = 0; index < width; index++)
            sum += values[index];
        result[0] = sum;
        for (var index = width; index < values.Count; index++)
        {
            sum += values[index] - values[index - width];
            result[index - width + 1] = sum;
        }

        return result;
    }
}
