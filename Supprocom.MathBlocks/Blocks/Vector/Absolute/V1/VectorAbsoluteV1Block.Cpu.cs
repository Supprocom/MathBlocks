namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.absolute@1</c> mathematical operation.</summary>
    public static float[] Absolute(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, Math.Abs);
    }
}
