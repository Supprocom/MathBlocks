namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.exponential-moving-average@1</c> mathematical operation.</summary>
    public static float[] ExponentialMovingAverage(IReadOnlyList<float> values, float alpha)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count];
        result[0] = values[0];
        for (var index = 1; index < values.Count; index++)
            result[index] = alpha * values[index] + (1f - alpha) * result[index - 1];
        return result;
    }
}
