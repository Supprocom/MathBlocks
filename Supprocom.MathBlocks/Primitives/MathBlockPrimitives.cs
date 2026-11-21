namespace Supprocom.MathBlocks;

internal static class MathBlockPrimitives
{
    public const float PI = 3.141592653589793238462643383279502884f;
    public const float E = 2.718281828459045235360287471352662498f;

    public static float PositiveInfinity => FromBits(0x7ff0_0000_0000_0000ul);
    public static float NegativeInfinity => FromBits(0xfff0_0000_0000_0000ul);
    public static float NaN => FromBits(0x7ff8_0000_0000_0000ul);

    public static float Abs(float value) => FromBits(ToBits(value) & 0x7fff_ffff_ffff_fffful);

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

    public static float CopySign(float magnitude, float sign) =>
        FromBits((ToBits(magnitude) & 0x7fff_ffff_ffff_fffful) | (ToBits(sign) & 0x8000_0000_0000_0000ul));

    public static int Sign(float value) => value > 0f ? 1 : value < 0f ? -1 : 0;

    // IEEE 754-2019 minimum and maximum: a NaN operand gives NaN, and -0 is less than +0.
    public static float Min(float left, float right)
    {
        if (IsNaN(left) || IsNaN(right))
            return NaN;
        if (left < right)
            return left;
        if (right < left)
            return right;
        if (left == 0f)
            return IsNegative(left) ? left : right;
        return left;
    }

    public static int Min(int left, int right) => left < right ? left : right;

    public static float Max(float left, float right)
    {
        if (IsNaN(left) || IsNaN(right))
            return NaN;
        if (left > right)
            return left;
        if (right > left)
            return right;
        if (left == 0f)
            return IsNegative(left) ? right : left;
        return left;
    }

    public static int Max(int left, int right) => left > right ? left : right;

    public static float Clamp(float value, float lower, float upper)
    {
        if (lower > upper)
            throw new ArgumentException("The lower limit exceeds the upper limit.");
        return value < lower ? lower : value > upper ? upper : value;
    }

    public static float Truncate(float value)
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

    public static float Floor(float value)
    {
        var truncated = Truncate(value);
        return value < truncated ? truncated - 1f : truncated;
    }

    public static float Ceiling(float value)
    {
        var truncated = Truncate(value);
        return value > truncated ? truncated + 1f : truncated;
    }

    public static float Round(float value)
    {
        if (!IsFinite(value) || Abs(value) >= 4_503_599_627_370_496f)
            return value;
        var magnitude = Abs(value);
        var integral = Truncate(magnitude);
        var fraction = magnitude - integral;
        if (fraction > 0.5f || (fraction == 0.5f && (((long)integral & 1L) != 0L)))
            integral += 1f;
        return CopySign(integral, value);
    }

    public static float Round(float value, MidpointRounding mode)
    {
        if (mode != MidpointRounding.ToEven)
            throw new ArgumentOutOfRangeException(nameof(mode));
        return Round(value);
    }

    // IEEE 754 requires the square root to be correctly rounded, so the base library's Math.Sqrt (the hardware
    // instruction) and CUDA's double sqrt give the same bits for every input. It is the one member of the base
    // library's Math class that the library calls.
    public static float Sqrt(float value)
    {
        if (value == 0f || IsPositiveInfinity(value))
            return value;
        if (value < 0f || IsNaN(value))
            return QuietNaN();
        return System.Math.Sqrt(value);
    }

    public static int ILogB(float value)
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
    public static float ScaleB(float value, int exponent)
    {
        if (value == 0f || !IsFinite(value))
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

    public static float Exp(float value) => MathBlockScalar.Exponential(value);
    public static float Log(float value) => MathBlockScalar.NaturalLogarithm(value);
    public static float Log2(float value) => MathBlockScalar.BinaryLogarithm(value);
    public static float Pow(float value, float exponent) => MathBlockScalar.Power(value, exponent);
    public static float Sin(float value) => MathBlockScalar.Sine(value);
    public static float Cos(float value) => MathBlockScalar.Cosine(value);
    public static float Atan2(float y, float x) => MathBlockScalar.ArcTangent2(y, x);
    public static float Cbrt(float value) => MathBlockScalar.CubeRoot(value);

    public static float Asin(float value)
    {
        if (value < -1f || value > 1f || IsNaN(value))
            return QuietNaN();
        return Atan2(value, Sqrt((1f - value) * (1f + value)));
    }

    public static float Acos(float value)
    {
        if (value < -1f || value > 1f || IsNaN(value))
            return QuietNaN();
        return Atan2(Sqrt((1f - value) * (1f + value)), value);
    }

    public static bool IsFinite(float value) =>
        (ToBits(value) & 0x7ff0_0000_0000_0000ul) != 0x7ff0_0000_0000_0000ul;

    public static bool IsNaN(float value) =>
        (ToBits(value) & 0x7fff_ffff_ffff_fffful) > 0x7ff0_0000_0000_0000ul;

    public static bool IsPositiveInfinity(float value) => ToBits(value) == 0x7ff0_0000_0000_0000ul;

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

    private static bool IsNegative(float value) => (ToBits(value) & 0x8000_0000_0000_0000ul) != 0ul;
    private static float QuietNaN() => FromBits(0x7ff8_0000_0000_0000ul);

    internal static unsafe ulong ToBits(float value) => *(ulong*)&value;
    internal static unsafe float FromBits(ulong value) => *(float*)&value;
}
