namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double Logistic(double value) => value >= 0d ? 1d / (1d + DeterministicExponential(-value)) : DeterministicExponential(value) / (1d + DeterministicExponential(value));
}
