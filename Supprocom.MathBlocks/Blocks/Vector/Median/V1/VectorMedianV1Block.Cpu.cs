namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.median@1</c> mathematical operation.</summary>
    public static float Median(IReadOnlyList<float> values) => Quantile(values, 0.5f);
}
