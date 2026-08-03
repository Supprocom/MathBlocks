namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double Power(double value, double exponent)
    {
        if (exponent == Math.Truncate(exponent) && Math.Abs(exponent) <= long.MaxValue)
            return IntegerPower(value, (long)exponent);
        if (value < 0d)
            return Math.NaN;
        if (value == 0d)
            return exponent > 0d ? 0d : Math.PositiveInfinity;
        return Exponential(exponent * NaturalLogarithm(value));
    }
}
