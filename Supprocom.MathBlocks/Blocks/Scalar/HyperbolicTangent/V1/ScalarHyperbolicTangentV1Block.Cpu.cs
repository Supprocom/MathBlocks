namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.hyperbolic-tangent@1</c> mathematical operation.</summary>
    public static float HyperbolicTangent(float value)
    {
        // Odd function: f(-0) = -0 and f(+0) = +0, as IEEE 754 gives it.
        if (value == 0f)
            return value;
        // Beyond 20 the result is +-1 (the formula below already gives exactly +-1 up to 88.7); past the logarithm of the largest single the
        // exponentials overflow and the quotient would be infinity over infinity, which is NaN.
        if (Math.Abs(value) > 20f)
            return Math.CopySign(1f, value);
        var positive = DeterministicExponential(value);
        var negative = DeterministicExponential(-value);
        return (positive - negative) / (positive + negative);
    }
}
