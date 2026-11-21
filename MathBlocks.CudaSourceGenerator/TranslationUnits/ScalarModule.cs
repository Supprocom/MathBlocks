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
        return MathF.ScaleB(result, exponent);
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
        float reduced = MathF.ScaleB(value, -exponent);
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
        float octant_value = MathF.Floor(x / 0.78539816339744830962f);
        int octant = (int)(octant_value - MathF.Floor(octant_value * 0.125f) * 8.0f);
        if ((octant & 1) != 0)
        {
            octant++;
            octant_value++;
        }
        octant &= 7;
        if (octant > 3)
        {
            sign = -sign;
            octant -= 4;
        }
        float reduced = ((x - octant_value * 0.78515625f) -
                          octant_value * 0.00024187564849853515625f) -
                         octant_value * 0.0000000377489497744594108f;
        float square = reduced * reduced;
        if (octant == 1 || octant == 2)
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
        float sign = 1.0f;
        float octant_value = MathF.Floor(x / 0.78539816339744830962f);
        int octant = (int)(octant_value - MathF.Floor(octant_value * 0.125f) * 8.0f);
        if ((octant & 1) != 0)
        {
            octant++;
            octant_value++;
        }
        octant &= 7;
        if (octant > 3)
        {
            octant -= 4;
            sign = -sign;
        }
        if (octant > 1)
            sign = -sign;
        float reduced = ((x - octant_value * 0.78515625f) -
                          octant_value * 0.00024187564849853515625f) -
                         octant_value * 0.0000000377489497744594108f;
        float square = reduced * reduced;
        if (octant == 1 || octant == 2)
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
            case 38: result = a % b; break;
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
