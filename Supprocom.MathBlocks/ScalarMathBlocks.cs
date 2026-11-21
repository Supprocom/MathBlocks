namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{

    private static float DeterministicArcTangent(float value)
    {
        // Odd function: f(-0) = -0 and f(+0) = +0, as IEEE 754 gives it.
        if (value == 0f)
            return value;
        var sign = value < 0f ? -1f : 1f;
        var x = Math.Abs(value);
        var offset = 0f;
        if (x > 2.4142135623730950488f)
        {
            offset = Math.PI / 2f;
            x = -1f / x;
        }
        else if (x > 0.4142135623730950488f)
        {
            offset = Math.PI / 4f;
            x = (x - 1f) / (x + 1f);
        }

        var z = x * x;
        var numerator = ((((
            -0.8750608600031904122785f * z - 16.15753718733365076637f) * z -
            75.00855792314704667340f) * z - 122.8866684490136173410f) * z -
            64.85021904942025371773f);
        var denominator = (((((
            z + 24.85846490142306297962f) * z + 165.0270098316988542046f) * z +
            432.8810604912902668951f) * z + 485.3903996359136964868f) * z +
            194.5506571482613964425f);
        return sign * (offset + x + x * z * numerator / denominator);
    }

    private static float DeterministicSine(float value)
    {
        // Odd function: f(-0) = -0 and f(+0) = +0, as IEEE 754 gives it.
        if (value == 0f)
            return value;
        var sign = 1f;
        var x = value;
        if (x < 0f)
        {
            sign = -1f;
            x = -x;
        }
        var octantValue = Math.Floor(x / 0.78539816339744830962f);
        var octant = (int)(octantValue - Math.Floor(octantValue * 0.125f) * 8f);
        if ((octant & 1) != 0)
        {
            octant++;
            octantValue++;
        }
        octant &= 7;
        if (octant > 3)
        {
            sign = -sign;
            octant -= 4;
        }
        // A quarter of pi in three parts for single precision: the first has eight bits, so its product with the octant is exact.
        var reduced = ((x - octantValue * 0.78515625f) -
                       octantValue * 0.00024187564849853515625f) -
                      octantValue * 0.0000000377489497744594108f;
        var square = reduced * reduced;
        if (octant is 1 or 2)
        {
            var polynomial = (((((
                -0.0000000000113585365213876817300f * square +
                0.00000000208757008419747316778f) * square -
                0.000000275573141792967388112f) * square +
                0.0000248015872888517045348f) * square -
                0.00138888888888730564116f) * square +
                0.0416666666666665929218f);
            return sign * (1f - 0.5f * square + square * square * polynomial);
        }
        var sinePolynomial = (((((
            0.000000000158962301576546568060f * square -
            0.0000000250507477628578072866f) * square +
            0.00000275573136213857245213f) * square -
            0.000198412698295895385996f) * square +
            0.00833333333332211858878f) * square -
            0.166666666666666307295f);
        return sign * (reduced + reduced * square * sinePolynomial);
    }

    private static float DeterministicCosine(float value)
    {
        var x = Math.Abs(value);
        var sign = 1f;
        var octantValue = Math.Floor(x / 0.78539816339744830962f);
        var octant = (int)(octantValue - Math.Floor(octantValue * 0.125f) * 8f);
        if ((octant & 1) != 0)
        {
            octant++;
            octantValue++;
        }
        octant &= 7;
        if (octant > 3)
        {
            octant -= 4;
            sign = -sign;
        }
        if (octant > 1)
            sign = -sign;
        // A quarter of pi in three parts for single precision: the first has eight bits, so its product with the octant is exact.
        var reduced = ((x - octantValue * 0.78515625f) -
                       octantValue * 0.00024187564849853515625f) -
                      octantValue * 0.0000000377489497744594108f;
        var square = reduced * reduced;
        if (octant is 1 or 2)
        {
            var sinePolynomial = (((((
                0.000000000158962301576546568060f * square -
                0.0000000250507477628578072866f) * square +
                0.00000275573136213857245213f) * square -
                0.000198412698295895385996f) * square +
                0.00833333333332211858878f) * square -
                0.166666666666666307295f);
            return sign * (reduced + reduced * square * sinePolynomial);
        }
        var polynomial = (((((
            -0.0000000000113585365213876817300f * square +
            0.00000000208757008419747316778f) * square -
            0.000000275573141792967388112f) * square +
            0.0000248015872888517045348f) * square -
            0.00138888888888730564116f) * square +
            0.0416666666666665929218f);
        return sign * (1f - 0.5f * square + square * square * polynomial);
    }

    private static float DeterministicExponential(float value)
    {
        // Above the logarithm of the largest single the result is infinite; below the logarithm of half the smallest subnormal it is zero.
        if (value > 88.72283905206835f)
            return Math.PositiveInfinity;
        if (value < -103.97208065307015f)
            return 0f;

        var result = ReduceExponential(value, out var exponent);
        return Math.ScaleB(result, exponent);
    }

    // exp(value) = result * 2^exponent, with result near 1: the range reduction and rational approximation of
    // DeterministicExponential before the final scaling.
    private static float ReduceExponential(float value, out int exponent)
    {
        var exponentValue = Math.Floor(1.44269504088896340736f * value + 0.5f);
        exponent = (int)exponentValue;
        var reduced = value - exponentValue * 0.693359375f;
        reduced -= exponentValue * -0.000212194440054690582768f;
        var square = reduced * reduced;
        var numerator = reduced * ((
            0.000126177193074810590878f * square + 0.03029944077074419613f) * square + 1f);
        var denominator = (((
            0.00000300198505138664455042f * square + 0.00252448340349684104192f) * square +
            0.227265548208155028766f) * square + 2f);
        return 1f + 2f * numerator / (denominator - numerator);
    }

    private static float DeterministicNaturalLogarithm(float value)
    {
        if (value == 0f)
            return Math.NegativeInfinity;
        if (value < 0f || Math.IsNaN(value))
            return Math.NaN;
        if (float.IsPositiveInfinity(value))
            return Math.PositiveInfinity;

        var exponent = Math.ILogB(value) + 1;
        var reduced = Math.ScaleB(value, -exponent);
        if (reduced < 0.70710678118654752440f)
        {
            exponent--;
            reduced = 2f * reduced - 1f;
        }
        else
        {
            reduced -= 1f;
        }

        var square = reduced * reduced;
        var numerator = (((((
            0.000101875663804580931796f * reduced + 0.497494994976747001425f) * reduced +
            4.70579119878881725854f) * reduced + 14.4989225341610930846f) * reduced +
            17.9368678507819816313f) * reduced + 7.70838733755885391666f);
        var denominator = (((((
            reduced + 11.2873587189167450590f) * reduced + 45.2279145837532221105f) * reduced +
            82.9875266912776603211f) * reduced + 71.1544750618563894466f) * reduced +
            23.1251620126765340583f);
        var correction = reduced * (square * numerator / denominator);
        correction -= exponent * 0.000212194440054690582768f;
        correction -= 0.5f * square;
        return reduced + correction + exponent * 0.693359375f;
    }

    private static float IntegerPower(float value, long exponent)
    {
        if (exponent == 0)
            return 1f;
        var negative = exponent < 0;
        var remaining = negative ? unchecked((ulong)(-(exponent + 1)) + 1ul) : (ulong)exponent;
        var powerBase = value;
        var result = 1f;
        while (remaining != 0ul)
        {
            if ((remaining & 1ul) != 0ul)
                result *= powerBase;
            remaining >>= 1;
            if (remaining != 0ul)
                powerBase *= powerBase;
        }
        return negative ? 1f / result : result;
    }
}

internal static partial class ScalarMathBlocks
{

    private static void AddDimensionlessUnary(
        ICollection<MathBlockOperation> operations,
        string identifier,
        Func<float, float> function,
        float sample,
        float expected) =>
        operations.Add(MathBlockOperationFactory.ScalarUnary(
            identifier, function, sample, expected, MathBlockTypeRules.DimensionlessScalar));

    private static MathBlockOperation CreateBooleanBinary(
        string identifier,
        Func<bool, bool, bool> function,
        bool left,
        bool right,
        bool expected) => MathBlockOperationFactory.Create(
        identifier, 2,
        types => MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Boolean),
        inputs => MathBlockValue.Boolean(function(inputs[0].AsBoolean(), inputs[1].AsBoolean())),
        [MathBlockValue.Boolean(left), MathBlockValue.Boolean(right)],
        MathBlockValue.Boolean(expected),
        performanceIterations: 512);
}
