namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.add-scalar@1</c> mathematical operation.</summary>
    public static float[] AddScalar(IReadOnlyList<float> values, float scalar)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, value => value + scalar);
    }
}
