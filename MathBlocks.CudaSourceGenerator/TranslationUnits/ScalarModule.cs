#pragma warning disable CS0078, CS0649

using System;
using Supprocom.CSharp2CUDA;

[TranspileToCUDA]
internal static unsafe class ScalarModule
{
    [CudaExternal(IsPure = true)]
    private static int mathblocks_limit_cube_root_newton_steps() => throw new NotSupportedException();

    // The value of each of these operations is defined once, in the device prelude's mathblocks_row_value_* functions (the mathblocks_row_* functions a
    // consumer calls wrap them), so the dispatch, the elementwise rows and a consumer's kernel give the same bits.
    [CudaExternal(IsPure = true)]
    private static float mathblocks_row_value_add(float a, float b) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_row_value_subtract(float a, float b) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_row_value_multiply(float a, float b) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_row_value_divide(float a, float b) => throw new NotSupportedException();

    [CudaExternal(IsPure = true)]
    private static float mathblocks_row_value_absolute(float a) => throw new NotSupportedException();

    public struct MathBlockSlot
    {
        public float scalar_value;
        public ulong data_pointer;
        public ulong scratch_pointer;
        public CudaInt32 boolean_value;
        public CudaInt32 valid;
        public int rows;
        public int columns;
        public int count;
        public int capacity;
    }

    [CudaDevice]
    private static float mathblocks_positive_infinity()
    {
        return BitConverter.Int32BitsToSingle(0x7f800000);
    }

    [CudaDevice]
    private static float mathblocks_quiet_nan()
    {
        return BitConverter.Int32BitsToSingle(0x7fc00000);
    }

    [CudaDevice]
    private static float mathblocks_square_root(float value)
    {
        if (value == 0.0f || (float.IsInfinity(value) && value > 0.0f))
            return value;
        if (value < 0.0f || float.IsNaN(value))
            return mathblocks_quiet_nan();
        // CUDA's double sqrt is correctly rounded, as IEEE 754 requires, so it gives CoreCLR's System.Math.Sqrt bits.
        return MathF.Sqrt(value);
    }

    // value * 2^exponent rounded once to nearest, the result of the CoreCLR primitive. Every multiplication before the last is by a power of two
    // that leaves the product exact (2^127 going up; 2^-102 going down, which keeps 24 bits above the smallest normal), so only the last one
    // rounds (the method of musl's scalbnf). The device's own ldexpf is not used: it compiles to an approximate instruction.
    [CudaDevice]
    private static float mathblocks_scale_binary(float value, int exponent)
    {
        float scaled = value;
        int remaining = exponent;
        if (remaining > 127)
        {
            scaled *= 1.7014118346046923e38f;
            remaining -= 127;
            if (remaining > 127)
            {
                scaled *= 1.7014118346046923e38f;
                remaining -= 127;
                if (remaining > 127)
                    remaining = 127;
            }
        }
        else if (remaining < -126)
        {
            scaled *= 1.9721522630525295e-31f;
            remaining += 102;
            if (remaining < -126)
            {
                scaled *= 1.9721522630525295e-31f;
                remaining += 102;
                if (remaining < -126)
                    remaining = -126;
            }
        }

        return scaled * BitConverter.Int32BitsToSingle((remaining + 127) << 23);
    }

    // The remainder of value / modulus with the sign of value (C's fmod, the CoreCLR % operator), exact: the two significands are reduced as
    // integers, at most 40 bits of the quotient at a time, and the remainder is below 2^24, so scaling it back only moves its exponent. The
    // device's own fmodf is not used: it compiles to an approximate instruction.
    [CudaDevice]
    private static float mathblocks_modulo(float value, float modulus)
    {
        uint valueBits = (uint)BitConverter.SingleToInt32Bits(value);
        uint modulusBits = (uint)BitConverter.SingleToInt32Bits(modulus);
        uint sign = valueBits & 0x80000000u;
        uint magnitude = valueBits & 0x7fffffffu;
        uint divisor = modulusBits & 0x7fffffffu;
        if (divisor == 0u || magnitude >= 0x7f800000u || divisor > 0x7f800000u)
            return mathblocks_quiet_nan();
        if (magnitude < divisor)
            return value;

        int valueExponent = (int)(magnitude >> 23);
        int modulusExponent = (int)(divisor >> 23);
        ulong remainder = magnitude & 0x007fffffu;
        ulong step = divisor & 0x007fffffu;
        if (valueExponent == 0)
            valueExponent = 1;
        else
            remainder |= 0x00800000u;
        if (modulusExponent == 0)
            modulusExponent = 1;
        else
            step |= 0x00800000u;

        int shift = valueExponent - modulusExponent;
        remainder %= step;
        while (shift > 0)
        {
            int count = shift < 40 ? shift : 40;
            remainder = (remainder << count) % step;
            shift -= count;
        }

        float scaled = mathblocks_scale_binary((float)remainder, modulusExponent - 150);
        return BitConverter.Int32BitsToSingle((int)((uint)BitConverter.SingleToInt32Bits(scaled) | sign));
    }

    [CudaDevice]
    private static float mathblocks_exponential(float value)
    {
        if (value > 88.72283905206835f)
            return mathblocks_positive_infinity();
        if (value < -103.97208065307015f)
            return 0.0f;

        float exponent_value = MathF.Floor(1.44269504088896340736f * value + 0.5f);
        int exponent = (int)exponent_value;
        float reduced = value - exponent_value * 0.693359375f;
        reduced -= exponent_value * -0.000212194440054690582768f;
        float square = reduced * reduced;
        float numerator = reduced * ((
            0.000126177193074810590878f * square + 0.03029944077074419613f) * square + 1.0f);
        float denominator = (((
            0.00000300198505138664455042f * square + 0.00252448340349684104192f) * square +
            0.227265548208155028766f) * square + 2.0f);
        float result = 1.0f + 2.0f * numerator / (denominator - numerator);
        return mathblocks_scale_binary(result, exponent);
    }

    [CudaDevice]
    private static float mathblocks_natural_logarithm(float value)
    {
        if (value == 0.0f)
            return -mathblocks_positive_infinity();
        if (value < 0.0f || float.IsNaN(value))
            return mathblocks_quiet_nan();
        if (float.IsInfinity(value))
            return mathblocks_positive_infinity();

        int exponent = MathF.ILogB(value) + 1;
        float reduced = mathblocks_scale_binary(value, -exponent);
        if (reduced < 0.70710678118654752440f)
        {
            exponent--;
            reduced = 2.0f * reduced - 1.0f;
        }
        else
        {
            reduced -= 1.0f;
        }

        float square = reduced * reduced;
        float numerator = (((((
            0.000101875663804580931796f * reduced + 0.497494994976747001425f) * reduced +
            4.70579119878881725854f) * reduced + 14.4989225341610930846f) * reduced +
            17.9368678507819816313f) * reduced + 7.70838733755885391666f);
        float denominator = (((((
            reduced + 11.2873587189167450590f) * reduced + 45.2279145837532221105f) * reduced +
            82.9875266912776603211f) * reduced + 71.1544750618563894466f) * reduced +
            23.1251620126765340583f);
        float correction = reduced * (square * numerator / denominator);
        correction -= exponent * 0.000212194440054690582768f;
        correction -= 0.5f * square;
        return reduced + correction + exponent * 0.693359375f;
    }

    [CudaDevice]
    private static float mathblocks_log_one_plus(float value)
    {
        float sum = 1.0f + value;
        return sum == 1.0f
            ? value
            : mathblocks_natural_logarithm(sum) - ((sum - 1.0f) - value) / sum;
    }

    [CudaDevice]
    private static float mathblocks_binary_logarithm(float value)
    {
        uint bits = (uint)BitConverter.SingleToInt32Bits(value);
        int exponent = (int)((bits >> 23) & 0xffu);
        uint fraction = bits & 0x007fffffu;
        if (exponent > 0 && exponent < 0xff && fraction == 0u)
            return (float)(exponent - 127);
        return mathblocks_natural_logarithm(value) / 0.69314718055994530942f;
    }

    [CudaDevice]
    private static float mathblocks_integer_power(float value, long exponent)
    {
        if (exponent == 0)
            return 1.0f;
        bool negative = exponent < 0;
        ulong remaining = negative
            ? (ulong)(-(exponent + 1)) + 1UL
            : (ulong)exponent;
        float power_base = value;
        float result = 1.0f;
        while (remaining != 0UL)
        {
            if ((remaining & 1UL) != 0UL)
                result *= power_base;
            remaining >>= 1;
            if (remaining != 0UL)
                power_base *= power_base;
        }
        return negative ? 1.0f / result : result;
    }

    [CudaDevice]
    private static float mathblocks_power(float value, float exponent)
    {
        if (exponent == MathF.Truncate(exponent) && MathF.Abs(exponent) <= 9223372036854775807.0f)
            return mathblocks_integer_power(value, (long)exponent);
        if (value < 0.0f)
            return mathblocks_quiet_nan();
        if (value == 0.0f)
            return exponent > 0.0f ? 0.0f : mathblocks_positive_infinity();
        return mathblocks_exponential(exponent * mathblocks_natural_logarithm(value));
    }

    // The cube root with the default three Newton steps, which the complex cube root of the probability family uses.
    [CudaDevice]
    private static float mathblocks_cube_root(float value) => mathblocks_cube_root_steps(value, 3);

    [CudaDevice]
    private static float mathblocks_cube_root_steps(float value, int newton_steps)
    {
        if (value == 0.0f)
            return value;
        float magnitude = MathF.Abs(value);
        float estimate = mathblocks_exponential(mathblocks_natural_logarithm(magnitude) / 3.0f);
        for (int iteration = 0; iteration < newton_steps; iteration++)
            estimate = (2.0f * estimate + magnitude / (estimate * estimate)) / 3.0f;
        return MathF.CopySign(estimate, value);
    }

    // The largest magnitude for which sine, cosine and tangent have a value (2^24); the same bound as MathBlockPrimitives.TrigonometricArgumentLimit.
    [CudaDevice]
    private static float mathblocks_trigonometric_argument_limit()
    {
        return 16777216.0f;
    }

    // The quarter-turn count of x, the same operations in the same order as DeterministicQuarterTurns (ScalarMathBlocks.cs), where the
    // reduction is described.
    [CudaDevice]
    private static int mathblocks_quarter_turns(float x)
    {
        int count = (int)(x * 0.63661975f + 0.5f);
        float high = (float)((count >> 12) << 12);
        float low = (float)(count & 4095);
        float leading = ((x - high * 1.5708008f) - low * 1.5708008f) - high * -4.4535846e-06f;
        int correction = (leading > 0.78539816339744830962f ? 1 : 0) - (leading < -0.78539816339744830962f ? 1 : 0);
        return count + correction;
    }

    [CudaDevice]
    private static float mathblocks_reduce_by_quarter_turns(float x, int count)
    {
        float high = (float)((count >> 12) << 12);
        float low = (float)(count & 4095);
        float leading = ((x - high * 1.5708008f) - low * 1.5708008f) - high * -4.4535846e-06f;
        float trailing = low * 1.6446172e-26f + high * 1.6446172e-26f;
        trailing = trailing + low * 3.281839e-22f;
        trailing = trailing + high * 3.281839e-22f;
        trailing = trailing + low * 5.7208605e-18f;
        trailing = trailing + high * 5.7208605e-18f;
        trailing = trailing + low * 6.2228e-14f;
        trailing = trailing + high * 6.2228e-14f;
        trailing = trailing + low * -8.706138e-10f;
        trailing = trailing + high * -8.706138e-10f;
        trailing = trailing + low * -4.4535846e-06f;
        return leading - trailing;
    }

    [CudaDevice]
    private static float mathblocks_sine(float value)
    {
        // Odd function: f(-0) = -0 and f(+0) = +0, as IEEE 754 gives it.
        if (value == 0.0f)
            return value;
        float sign = 1.0f;
        float x = value;
        if (x < 0.0f)
        {
            sign = -1.0f;
            x = -x;
        }
        // Beyond the domain, and for NaN and the infinities, there is no value.
        if (!(x <= mathblocks_trigonometric_argument_limit()))
            return mathblocks_quiet_nan();
        int count = mathblocks_quarter_turns(x);
        float reduced = mathblocks_reduce_by_quarter_turns(x, count);
        int quadrant = count & 3;
        if ((quadrant & 2) != 0)
            sign = -sign;
        float square = reduced * reduced;
        if ((quadrant & 1) != 0)
        {
            float polynomial = (((((
                -0.0000000000113585365213876817300f * square +
                0.00000000208757008419747316778f) * square -
                0.000000275573141792967388112f) * square +
                0.0000248015872888517045348f) * square -
                0.00138888888888730564116f) * square +
                0.0416666666666665929218f);
            return sign * (1.0f - 0.5f * square + square * square * polynomial);
        }
        float sine_polynomial = (((((
            0.000000000158962301576546568060f * square -
            0.0000000250507477628578072866f) * square +
            0.00000275573136213857245213f) * square -
            0.000198412698295895385996f) * square +
            0.00833333333332211858878f) * square -
            0.166666666666666307295f);
        return sign * (reduced + reduced * square * sine_polynomial);
    }

    [CudaDevice]
    private static float mathblocks_cosine(float value)
    {
        float x = MathF.Abs(value);
        // Beyond the domain, and for NaN and the infinities, there is no value.
        if (!(x <= mathblocks_trigonometric_argument_limit()))
            return mathblocks_quiet_nan();
        int count = mathblocks_quarter_turns(x);
        float reduced = mathblocks_reduce_by_quarter_turns(x, count);
        int quadrant = count & 3;
        float sign = 1.0f;
        if (((quadrant + 1) & 2) != 0)
            sign = -sign;
        float square = reduced * reduced;
        if ((quadrant & 1) != 0)
        {
            float sine_polynomial = (((((
                0.000000000158962301576546568060f * square -
                0.0000000250507477628578072866f) * square +
                0.00000275573136213857245213f) * square -
                0.000198412698295895385996f) * square +
                0.00833333333332211858878f) * square -
                0.166666666666666307295f);
            return sign * (reduced + reduced * square * sine_polynomial);
        }
        float polynomial = (((((
            -0.0000000000113585365213876817300f * square +
            0.00000000208757008419747316778f) * square -
            0.000000275573141792967388112f) * square +
            0.0000248015872888517045348f) * square -
            0.00138888888888730564116f) * square +
            0.0416666666666665929218f);
        return sign * (1.0f - 0.5f * square + square * square * polynomial);
    }

    [CudaDevice]
    private static float mathblocks_arc_tangent(float value)
    {
        // Odd function: f(-0) = -0 and f(+0) = +0, as IEEE 754 gives it.
        if (value == 0.0f)
            return value;
        float sign = value < 0.0f ? -1.0f : 1.0f;
        float x = MathF.Abs(value);
        float offset = 0.0f;
        if (x > 2.4142135623730950488f)
        {
            offset = 3.14159265358979323846f / 2.0f;
            x = -1.0f / x;
        }
        else if (x > 0.4142135623730950488f)
        {
            offset = 3.14159265358979323846f / 4.0f;
            x = (x - 1.0f) / (x + 1.0f);
        }

        float z = x * x;
        float numerator = ((((
            -0.8750608600031904122785f * z - 16.15753718733365076637f) * z -
            75.00855792314704667340f) * z - 122.8866684490136173410f) * z -
            64.85021904942025371773f);
        float denominator = (((((
            z + 24.85846490142306297962f) * z + 165.0270098316988542046f) * z +
            432.8810604912902668951f) * z + 485.3903996359136964868f) * z +
            194.5506571482613964425f);
        return sign * (offset + x + x * z * numerator / denominator);
    }

    [CudaDevice]
    private static float mathblocks_arc_tangent_2(float y, float x)
    {
        const float pi = 3.14159265358979323846f;
        if (x > 0.0f)
            return mathblocks_arc_tangent(y / x);
        if (x < 0.0f)
            return !Cuda.SignBit(y)
                ? mathblocks_arc_tangent(y / x) + pi
                : mathblocks_arc_tangent(y / x) - pi;
        if (y > 0.0f)
            return pi / 2.0f;
        if (y < 0.0f)
            return -pi / 2.0f;
        // Both are zeros (IEEE 754, C99 Annex F): atan2(±0, +0) = ±0 and atan2(±0, -0) = ±pi.
        return Cuda.SignBit(x) ? MathF.CopySign(pi, y) : y;
    }

    [CudaDevice]
    private static float mathblocks_arc_cosine(float value)
    {
        if (value < -1.0f || value > 1.0f)
            return mathblocks_quiet_nan();
        return mathblocks_arc_tangent_2(
            mathblocks_square_root((1.0f - value) * (1.0f + value)),
            value);
    }

    [CudaDevice]
    private static float mathblocks_inverse_hyperbolic_sine(float value)
    {
        if (value == 0.0f)
            return value;
        float magnitude = MathF.Abs(value);
        return MathF.CopySign(
            mathblocks_natural_logarithm(magnitude + mathblocks_square_root(magnitude * magnitude + 1.0f)),
            value);
    }

    [CudaDevice]
    private static float mathblocks_error_function(float value)
    {
        // Odd function: f(-0) = -0 and f(+0) = +0, as IEEE 754 gives it.
        if (value == 0.0f)
            return value;
        float magnitude = MathF.Abs(value);
        float t = 1.0f / (1.0f + 0.5f * magnitude);
        float tau = t * mathblocks_exponential(
            -magnitude * magnitude - 1.26551223f +
            t * (1.00002368f +
            t * (0.37409196f +
            t * (0.09678418f +
            t * (-0.18628806f +
            t * (0.27886807f +
            t * (-1.13520398f +
            t * (1.48851587f +
            t * (-0.82215223f + t * 0.17087277f)))))))));
        return MathF.CopySign(1.0f - tau, value);
    }

    // The scalar-valued opcodes 0..43 on their arguments: writes the result to value and returns whether it is a
    // valid result (finite). The scalar dispatcher and the elementwise forms both evaluate their rows here.
    [CudaDevice]
    private static bool mathblocks_scalar_value(int opcode, float a, float b, float c, float* value)
    {
        float result = 0.0f;
        switch (opcode)
        {
            case 0: result = mathblocks_row_value_add(a, b); break;
            case 1: result = mathblocks_row_value_subtract(a, b); break;
            case 2: result = mathblocks_row_value_multiply(a, b); break;
            case 3: result = mathblocks_row_value_divide(a, b); break;
            case 4: result = -a; break;
            case 5: result = mathblocks_row_value_absolute(a); break;
            case 6: result = Cuda.Int(a > 0.0f) - Cuda.Int(a < 0.0f); break;
            case 7: result = a > 0.0f ? a : 0.0f; break;
            case 8: result = MathF.Min(a, b); break;
            case 9: result = MathF.Max(a, b); break;
            case 10:
                // Math.Clamp's rule: a lower limit above the upper limit is invalid; otherwise the value unless it
                // compares below the lower or above the upper limit, so a zero value keeps its sign at zero limits.
                if (b > c)
                {
                    *value = 0.0f;
                    return false;
                }
                result = a < b ? b : a > c ? c : a;
                break;
            case 11: result = 1.0f / a; break;
            case 12: result = a * a; break;
            case 13: result = a * a * a; break;
            case 14: result = mathblocks_square_root(a); break;
            case 15: result = mathblocks_cube_root_steps(a, mathblocks_limit_cube_root_newton_steps()); break;
            case 16: result = mathblocks_power(a, b); break;
            case 17: result = mathblocks_exponential(a); break;
            case 18: result = mathblocks_natural_logarithm(a); break;
            case 19: result = mathblocks_binary_logarithm(a); break;
            case 20:
                result = mathblocks_natural_logarithm(a) / 2.30258509299404568402f;
                break;
            case 21: result = mathblocks_sine(a); break;
            case 22: result = mathblocks_cosine(a); break;
            case 23: result = mathblocks_sine(a) / mathblocks_cosine(a); break;
            case 24: result = mathblocks_arc_sine(a); break;
            case 25: result = mathblocks_arc_cosine(a); break;
            case 26: result = mathblocks_arc_tangent(a); break;
            case 27: result = mathblocks_arc_tangent_2(a, b); break;
            case 28:
            {
                if (a == 0.0f)
                {
                    result = a;
                    break;
                }
                float positive = mathblocks_exponential(a);
                float negative = mathblocks_exponential(-a);
                result = (positive - negative) / 2.0f;
                break;
            }
            case 29:
            {
                float positive = mathblocks_exponential(a);
                float negative = mathblocks_exponential(-a);
                result = (positive + negative) / 2.0f;
                break;
            }
            case 30:
            {
                if (a == 0.0f)
                {
                    result = a;
                    break;
                }
                // Beyond 20 the result is +-1; see MathBlockScalar.HyperbolicTangent.
                if (MathF.Abs(a) > 20.0f)
                {
                    result = MathF.CopySign(1.0f, a);
                    break;
                }
                float positive = mathblocks_exponential(a);
                float negative = mathblocks_exponential(-a);
                result = (positive - negative) / (positive + negative);
                break;
            }
            case 31: result = mathblocks_inverse_hyperbolic_sine(a); break;
            case 32:
                result = mathblocks_natural_logarithm(
                    a + mathblocks_square_root(a * a - 1.0f));
                break;
            case 33: result = 0.5f * mathblocks_log_one_plus(2.0f * a / (1.0f - a)); break;
            case 34: result = MathF.Floor(a); break;
            case 35: result = MathF.Ceiling(a); break;
            case 36: result = MathF.Round(a); break;
            case 37: result = MathF.Truncate(a); break;
            case 38: result = mathblocks_modulo(a, b); break;
            case 39:
                result = a >= 0.0f
                    ? 1.0f / (1.0f + mathblocks_exponential(-a))
                    : mathblocks_exponential(a) / (1.0f + mathblocks_exponential(a));
                break;
            case 40:
                result = mathblocks_natural_logarithm(a / (1.0f - a));
                break;
            case 41:
                result = MathF.Max(a, 0.0f) +
                    mathblocks_log_one_plus(mathblocks_exponential(-MathF.Abs(a)));
                break;
            case 42: result = mathblocks_log_one_plus(a); break;
            case 43: result = mathblocks_error_function(a); break;
            default: *value = 0.0f; return false;
        }

        *value = result;
        return float.IsFinite(result);
    }

    [CudaDevice(Name = "mathblocks_scalar_dispatch")]
    private static void mathblocks_scalar(
        int opcode,
        MathBlockSlot** inputs,
        int input_count,
        MathBlockSlot* output)
    {
        if (Cuda.ThreadIdx.X != 0)
            return;

        MathBlockSlot* first = Cuda.ReadOnly(input_count > 0 ? inputs[0] : null);
        MathBlockSlot* second = Cuda.ReadOnly(input_count > 1 ? inputs[1] : null);
        MathBlockSlot* third = Cuda.ReadOnly(input_count > 2 ? inputs[2] : null);

        output->scalar_value = 0.0f;
        output->boolean_value = 0;
        output->valid = first == null || first->valid;
        if (second != null)
            output->valid = output->valid && second->valid;
        if (third != null)
            output->valid = output->valid && third->valid;
        if (!output->valid)
            return;

        float a = first == null ? 0.0f : first->scalar_value;
        float b = second == null ? 0.0f : second->scalar_value;
        float c = third == null ? 0.0f : third->scalar_value;
        if (opcode >= 0 && opcode <= 43)
        {
            float value = 0.0f;
            output->valid = mathblocks_scalar_value(opcode, a, b, c, &value);
            output->scalar_value = value;
            return;
        }

        bool scalar_output = true;
        switch (opcode)
        {
            case 44: output->boolean_value = a == b; scalar_output = false; break;
            case 45: output->boolean_value = a != b; scalar_output = false; break;
            case 46: output->boolean_value = a < b; scalar_output = false; break;
            case 47: output->boolean_value = a <= b; scalar_output = false; break;
            case 48: output->boolean_value = a > b; scalar_output = false; break;
            case 49: output->boolean_value = a >= b; scalar_output = false; break;
            case 50:
                output->boolean_value = first->boolean_value && second->boolean_value;
                scalar_output = false;
                break;
            case 51:
                output->boolean_value = first->boolean_value || second->boolean_value;
                scalar_output = false;
                break;
            case 52:
                output->boolean_value = first->boolean_value != second->boolean_value;
                scalar_output = false;
                break;
            case 53:
                output->boolean_value = !first->boolean_value;
                scalar_output = false;
                break;
            case 54:
                output->scalar_value = first->boolean_value ? second->scalar_value : third->scalar_value;
                break;
            default: output->valid = 0; return;
        }

        if (scalar_output && !float.IsFinite(output->scalar_value))
            output->valid = 0;
    }

    // Mirrors MathBlockPrimitives.Asin, so CoreCLR and CUDA use the same algorithm.
    [CudaDevice]
    private static float mathblocks_arc_sine(float value)
    {
        if (value < -1.0f || value > 1.0f || float.IsNaN(value))
            return mathblocks_quiet_nan();
        return mathblocks_arc_tangent_2(
            value,
            mathblocks_square_root((1.0f - value) * (1.0f + value)));
    }
}
