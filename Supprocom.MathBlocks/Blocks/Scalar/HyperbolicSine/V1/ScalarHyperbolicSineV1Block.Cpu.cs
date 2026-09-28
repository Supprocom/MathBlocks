namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.hyperbolic-sine@1</c> mathematical operation.</summary>
    public static double HyperbolicSine(double value)
    {
        var positive = DeterministicExponential(value);
        var negative = DeterministicExponential(-value);
        return (positive - negative) / 2d;
    }
}
