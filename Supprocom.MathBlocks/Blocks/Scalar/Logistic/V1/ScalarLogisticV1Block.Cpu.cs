namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.logistic@1</c> mathematical operation.</summary>
    public static float Logistic(float value) => value >= 0f ? 1f / (1f + DeterministicExponential(-value)) : DeterministicExponential(value) / (1f + DeterministicExponential(value));
}
