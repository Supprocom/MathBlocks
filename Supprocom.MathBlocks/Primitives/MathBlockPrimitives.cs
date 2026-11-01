namespace Supprocom.MathBlocks;

internal static class MathBlockPrimitives
{
    public const double PI = 3.141592653589793238462643383279502884d;
    public const double E = 2.718281828459045235360287471352662498d;

    public static double PositiveInfinity => FromBits(0x7ff0_0000_0000_0000ul);
    public static double NegativeInfinity => FromBits(0xfff0_0000_0000_0000ul);
    public static double NaN => FromBits(0x7ff8_0000_0000_0000ul);

    public static double Abs(double value) => FromBits(ToBits(value) & 0x7fff_ffff_ffff_fffful);

    public static int Abs(int value)
    {
        if (value >= 0)
            return value;
        if (value == int.MinValue)
            throw new OverflowException("The absolute integer value exceeds Int32.");
        return -value;
    }

    public static long Abs(long value)
    {
        if (value >= 0L)
            return value;
        if (value == long.MinValue)
            throw new OverflowException("The absolute integer value exceeds Int64.");
        return -value;
    }

    public static double CopySign(double magnitude, double sign) =>
        FromBits((ToBits(magnitude) & 0x7fff_ffff_ffff_fffful) | (ToBits(sign) & 0x8000_0000_0000_0000ul));

    public static int Sign(double value) => value > 0d ? 1 : value < 0d ? -1 : 0;

    // IEEE 754-2019 minimum and maximum: a NaN operand gives NaN, and -0 is less than +0.
    public static double Min(double left, double right)
    {
        if (IsNaN(left) || IsNaN(right))
            return NaN;
        if (left < right)
            return left;
        if (right < left)
            return right;
        if (left == 0d)
            return IsNegative(left) ? left : right;
        return left;
    }

    public static int Min(int left, int right) => left < right ? left : right;

    public static double Max(double left, double right)
    {
        if (IsNaN(left) || IsNaN(right))
            return NaN;
        if (left > right)
            return left;
        if (right > left)
            return right;
        if (left == 0d)
            return IsNegative(left) ? right : left;
        return left;
    }

    public static int Max(int left, int right) => left > right ? left : right;

    public static double Clamp(double value, double lower, double upper)
    {
        if (lower > upper)
            throw new ArgumentException("The lower limit exceeds the upper limit.");
        return value < lower ? lower : value > upper ? upper : value;
    }

    public static double Truncate(double value)
    {
        var bits = ToBits(value);
        var exponent = (int)((bits >> 52) & 0x7fful) - 1023;
        if (exponent < 0)
            return FromBits(bits & 0x8000_0000_0000_0000ul);
        if (exponent >= 52)
            return value;
        var fractionMask = (1ul << (52 - exponent)) - 1ul;
        return FromBits(bits & ~fractionMask);
    }

    public static double Floor(double value)
    {
        var truncated = Truncate(value);
        return value < truncated ? truncated - 1d : truncated;
    }

    public static double Ceiling(double value)
    {
        var truncated = Truncate(value);
        return value > truncated ? truncated + 1d : truncated;
    }

    public static double Round(double value)
    {
        if (!IsFinite(value) || Abs(value) >= 4_503_599_627_370_496d)
            return value;
        var magnitude = Abs(value);
        var integral = Truncate(magnitude);
        var fraction = magnitude - integral;
        if (fraction > 0.5d || (fraction == 0.5d && (((long)integral & 1L) != 0L)))
            integral += 1d;
        return CopySign(integral, value);
    }

    public static double Round(double value, MidpointRounding mode)
    {
        if (mode != MidpointRounding.ToEven)
            throw new ArgumentOutOfRangeException(nameof(mode));
        return Round(value);
    }

    // IEEE 754 requires the square root to be correctly rounded, so the base library's Math.Sqrt (the hardware
    // instruction) and CUDA's double sqrt give the same bits for every input. It is the one member of the base
    // library's Math class that the library calls.
    public static double Sqrt(double value)
    {
        if (value == 0d || IsPositiveInfinity(value))
            return value;
        if (value < 0d || IsNaN(value))
            return QuietNaN();
        return System.Math.Sqrt(value);
    }

    public static int ILogB(double value)
    {
        var bits = ToBits(Abs(value));
        var exponent = (int)((bits >> 52) & 0x7fful);
        var fraction = bits & 0x000f_ffff_ffff_fffful;
        if (exponent != 0)
            return exponent == 0x7ff ? int.MaxValue : exponent - 1023;
        if (fraction == 0ul)
            return int.MinValue;
        var result = -1022;
        while ((fraction & 0x0010_0000_0000_0000ul) == 0ul)
        {
            fraction <<= 1;
            result--;
        }
        return result;
    }

    // value * 2^exponent rounded once to nearest, ties to even (IEEE 754 scaleB, C ldexp), including subnormal
    // results: the significand is shifted to the result's last bit and rounded there.
    public static double ScaleB(double value, int exponent)
    {
        if (value == 0d || !IsFinite(value))
            return value;
        var bits = ToBits(value);
        var sign = bits & 0x8000_0000_0000_0000ul;
        var biased = (long)((bits >> 52) & 0x7fful);
        var significand = bits & 0x000f_ffff_ffff_fffful;
        if (biased == 0L)
        {
            // Subnormal input: normalize so the leading bit is bit 52.
            biased = 1L;
            while ((significand & 0x0010_0000_0000_0000ul) == 0ul)
            {
                significand <<= 1;
                biased--;
            }
        }
        else
        {
            significand |= 0x0010_0000_0000_0000ul;
        }

        // value = significand * 2^(biased - 1075); the result's biased exponent is biased + exponent.
        var target = biased + exponent;
        if (target >= 0x7ffL)
            return FromBits(sign | 0x7ff0_0000_0000_0000ul);
        if (target >= 1L)
            return FromBits(sign | ((ulong)target << 52) | (significand & 0x000f_ffff_ffff_fffful));

        // Below 2^-1022 the last bit is 2^-1074: keep significand >> (1 - target) and round the bits shifted out.
        // At a shift of 54 or more the value is below half of 2^-1074 and rounds to zero.
        var shift = 1L - target;
        if (shift >= 54L)
            return FromBits(sign);
        var quotient = significand >> (int)shift;
        var remainder = significand & ((1ul << (int)shift) - 1ul);
        var half = 1ul << (int)(shift - 1L);
        if (remainder > half || (remainder == half && (quotient & 1ul) != 0ul))
            quotient++;
        // A carry into bit 52 gives 2^-1022, whose encoding is the same bits.
        return FromBits(sign | quotient);
    }

    public static double Exp(double value) => MathBlockScalar.Exponential(value);
    public static double Log(double value) => MathBlockScalar.NaturalLogarithm(value);
    public static double Log2(double value) => MathBlockScalar.BinaryLogarithm(value);
    public static double Pow(double value, double exponent) => MathBlockScalar.Power(value, exponent);
    public static double Sin(double value) => MathBlockScalar.Sine(value);
    public static double Cos(double value) => MathBlockScalar.Cosine(value);
    public static double Atan2(double y, double x) => MathBlockScalar.ArcTangent2(y, x);
    public static double Cbrt(double value) => MathBlockScalar.CubeRoot(value);

    public static double Asin(double value)
    {
        if (value < -1d || value > 1d || IsNaN(value))
            return QuietNaN();
        return Atan2(value, Sqrt((1d - value) * (1d + value)));
    }

    public static double Acos(double value)
    {
        if (value < -1d || value > 1d || IsNaN(value))
            return QuietNaN();
        return Atan2(Sqrt((1d - value) * (1d + value)), value);
    }

    public static bool IsFinite(double value) =>
        (ToBits(value) & 0x7ff0_0000_0000_0000ul) != 0x7ff0_0000_0000_0000ul;

    public static bool IsNaN(double value) =>
        (ToBits(value) & 0x7fff_ffff_ffff_fffful) > 0x7ff0_0000_0000_0000ul;

    public static bool IsPositiveInfinity(double value) => ToBits(value) == 0x7ff0_0000_0000_0000ul;

    public static int FloorLog2(uint value)
    {
        ArgumentOutOfRangeException.ThrowIfEqual(value, 0u);
        var result = 0;
        while ((value >>= 1) != 0u)
            result++;
        return result;
    }

    public static int PopulationCount(uint value)
    {
        var result = 0;
        while (value != 0u)
        {
            value &= value - 1u;
            result++;
        }
        return result;
    }

    private static bool IsNegative(double value) => (ToBits(value) & 0x8000_0000_0000_0000ul) != 0ul;
    private static double QuietNaN() => FromBits(0x7ff8_0000_0000_0000ul);

    internal static unsafe ulong ToBits(double value) => *(ulong*)&value;
    internal static unsafe double FromBits(ulong value) => *(double*)&value;
}
