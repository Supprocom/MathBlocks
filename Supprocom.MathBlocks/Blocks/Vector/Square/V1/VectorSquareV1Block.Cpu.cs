namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.square@1</c> mathematical operation.</summary>
    public static float[] Square(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, value => value * value);
    }
}
