namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.logistic@1</c> mathematical operation.</summary>
    public static double Logistic(double value) => value >= 0d ? 1d / (1d + DeterministicExponential(-value)) : DeterministicExponential(value) / (1d + DeterministicExponential(value));
}
