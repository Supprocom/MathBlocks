namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.power@1</c> mathematical operation.</summary>
    public static float Power(float value, float exponent)
    {
        if (exponent == Math.Truncate(exponent) && Math.Abs(exponent) <= long.MaxValue)
            return IntegerPower(value, (long)exponent);
        if (value < 0f)
            return Math.NaN;
        if (value == 0f)
            return exponent > 0f ? 0f : Math.PositiveInfinity;
        return Exponential(exponent * NaturalLogarithm(value));
    }
}
