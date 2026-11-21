namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.minimum@1</c> mathematical operation.</summary>
    public static float Minimum(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = values[0];
        for (var index = 1; index < values.Count; index++)
            result = Math.Min(result, values[index]);
        return result;
    }
}
