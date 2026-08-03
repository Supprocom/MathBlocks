namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double BinaryLogarithm(double value)
    {
        var bits = Math.ToBits(value);
        var exponent = (int)((bits >> 52) & 0x7fful);
        var fraction = bits & 0x000f_ffff_ffff_fffful;
        if (exponent is> 0 and < 0x7ff && fraction == 0ul)
            return exponent - 1023;
        return DeterministicNaturalLogarithm(value) / 0.69314718055994530942d;
    }
}
