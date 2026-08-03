namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double Logit(double probability) => DeterministicNaturalLogarithm(probability / (1d - probability));
}
