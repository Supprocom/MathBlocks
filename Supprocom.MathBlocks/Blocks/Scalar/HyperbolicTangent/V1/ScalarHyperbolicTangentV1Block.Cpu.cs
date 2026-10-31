namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.hyperbolic-tangent@1</c> mathematical operation.</summary>
    public static double HyperbolicTangent(double value)
    {
        // Odd function: f(-0) = -0 and f(+0) = +0, as IEEE 754 gives it.
        if (value == 0d)
            return value;
        var positive = DeterministicExponential(value);
        var negative = DeterministicExponential(-value);
        return (positive - negative) / (positive + negative);
    }
}
