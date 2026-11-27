namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.tangent@1</c> mathematical operation. The domain is |value| &lt;= 2^24 (16777216), inclusive; beyond it, and for NaN and the infinities, the result is NaN and the row is invalid. The tangent is the sine over the cosine, so it has the same domain.</summary>
    public static float Tangent(float value) => DeterministicSine(value) / DeterministicCosine(value);
}
