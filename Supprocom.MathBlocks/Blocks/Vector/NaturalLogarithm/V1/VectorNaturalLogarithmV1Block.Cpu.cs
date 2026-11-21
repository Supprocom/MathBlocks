namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.natural-logarithm@1</c> mathematical operation.</summary>
    public static float[] NaturalLogarithm(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        return Map(values, MathBlockScalar.NaturalLogarithm);
    }
}
