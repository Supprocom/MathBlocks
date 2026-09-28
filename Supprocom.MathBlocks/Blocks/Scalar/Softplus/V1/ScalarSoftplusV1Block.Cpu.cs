namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.softplus@1</c> mathematical operation.</summary>
    public static double Softplus(double value) => Math.Max(value, 0d) + LogOnePlus(DeterministicExponential(-Math.Abs(value)));
}
