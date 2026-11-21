namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>probability.normal-cdf@1</c> mathematical operation.</summary>
    public static float NormalCdf(float value) => 0.5f * (1f + MathBlockScalar.ErrorFunction(value / Math.Sqrt(2f)));
}
