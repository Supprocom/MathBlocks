namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.subtract@1</c> mathematical operation.</summary>
    public static float[] Subtract(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        return Zip(left, right, MathBlockScalar.Subtract, MathBlockSimd.Subtract);
    }
}
