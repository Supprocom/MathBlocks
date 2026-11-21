namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>sequence.difference@1</c> mathematical operation.</summary>
    public static float[] Difference(IReadOnlyList<float> values, int lag = 1)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count - lag];
        for (var index = lag; index < values.Count; index++)
            result[index - lag] = values[index] - values[index - lag];
        return result;
    }
}
