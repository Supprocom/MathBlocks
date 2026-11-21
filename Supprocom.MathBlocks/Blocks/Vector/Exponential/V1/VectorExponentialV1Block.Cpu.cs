namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.exponential@1</c> mathematical operation.</summary>
    public static float[] Exponential(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, MathBlockScalar.Exponential);
    }
}
