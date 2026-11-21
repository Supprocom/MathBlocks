namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.inverse-hyperbolic-tangent@1</c> mathematical operation.</summary>
    public static float InverseHyperbolicTangent(float value) => 0.5f * LogOnePlus(2f * value / (1f - value));
}
