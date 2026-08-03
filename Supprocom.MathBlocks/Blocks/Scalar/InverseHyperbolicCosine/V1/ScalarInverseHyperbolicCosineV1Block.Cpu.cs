namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double InverseHyperbolicCosine(double value) => DeterministicNaturalLogarithm(value + Math.Sqrt(value * value - 1d));
}
