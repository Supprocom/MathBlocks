namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.sine@1</c> mathematical operation. The domain is |value| &lt;= 2^24 (16777216), inclusive; beyond it, and for NaN and the infinities, the result is NaN and the row is invalid.</summary>
    public static float Sine(float value) => DeterministicSine(value);
}
