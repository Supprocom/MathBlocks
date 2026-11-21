namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.positive-part@1</c> mathematical operation.</summary>
    public static float[] PositivePart(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, value => Math.Max(value, 0f));
    }
}
