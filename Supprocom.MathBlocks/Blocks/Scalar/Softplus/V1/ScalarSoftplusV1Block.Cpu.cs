namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double Softplus(double value) => Math.Max(value, 0d) + LogOnePlus(DeterministicExponential(-Math.Abs(value)));
}
