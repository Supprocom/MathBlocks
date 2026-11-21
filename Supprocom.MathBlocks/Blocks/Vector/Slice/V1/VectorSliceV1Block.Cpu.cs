namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.slice@1</c> mathematical operation.</summary>
    public static float[] Slice(IReadOnlyList<float> values, int start, int length)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[length];
        for (var index = 0; index < length; index++)
            result[index] = values[start + index];
        return result;
    }
}
