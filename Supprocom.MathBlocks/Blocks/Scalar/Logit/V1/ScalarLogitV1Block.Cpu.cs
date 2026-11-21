namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.logit@1</c> mathematical operation.</summary>
    public static float Logit(float probability) => DeterministicNaturalLogarithm(probability / (1f - probability));
}
