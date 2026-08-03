namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{

    private static double DeterministicArcTangent(double value)
    {
        var sign = value < 0d ? -1d : 1d;
        var x = Math.Abs(value);
        var offset = 0d;
        if (x > 2.4142135623730950488d)
        {
            offset = Math.PI / 2d;
            x = -1d / x;
        }
        else if (x > 0.4142135623730950488d)
        {
            offset = Math.PI / 4d;
            x = (x - 1d) / (x + 1d);
        }

        var z = x * x;
        var numerator = ((((
            -0.8750608600031904122785d * z - 16.15753718733365076637d) * z -
            75.00855792314704667340d) * z - 122.8866684490136173410d) * z -
            64.85021904942025371773d);
        var denominator = (((((
            z + 24.85846490142306297962d) * z + 165.0270098316988542046d) * z +
            432.8810604912902668951d) * z + 485.3903996359136964868d) * z +
            194.5506571482613964425d);
        return sign * (offset + x + x * z * numerator / denominator);
    }

    private static double DeterministicSine(double value)
    {
        var sign = 1d;
        var x = value;
        if (x < 0d)
        {
            sign = -1d;
            x = -x;
        }
        var octantValue = Math.Floor(x / 0.78539816339744830962d);
        var octant = (int)(octantValue - Math.Floor(octantValue * 0.125d) * 8d);
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
        var reduced = ((x - octantValue * 0.785398125648498535156d) -
                       octantValue * 0.0000000377489470793079817668d) -
                      octantValue * 0.00000000000000269515142907905952645d;
        var square = reduced * reduced;
        if (octant is 1 or 2)
        {
            var polynomial = (((((
                -0.0000000000113585365213876817300d * square +
                0.00000000208757008419747316778d) * square -
                0.000000275573141792967388112d) * square +
                0.0000248015872888517045348d) * square -
                0.00138888888888730564116d) * square +
                0.0416666666666665929218d);
            return sign * (1d - 0.5d * square + square * square * polynomial);
        }
        var sinePolynomial = (((((
            0.000000000158962301576546568060d * square -
            0.0000000250507477628578072866d) * square +
            0.00000275573136213857245213d) * square -
            0.000198412698295895385996d) * square +
            0.00833333333332211858878d) * square -
            0.166666666666666307295d);
        return sign * (reduced + reduced * square * sinePolynomial);
    }

    private static double DeterministicCosine(double value)
    {
        var x = Math.Abs(value);
        var sign = 1d;
        var octantValue = Math.Floor(x / 0.78539816339744830962d);
        var octant = (int)(octantValue - Math.Floor(octantValue * 0.125d) * 8d);
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
        var reduced = ((x - octantValue * 0.785398125648498535156d) -
                       octantValue * 0.0000000377489470793079817668d) -
                      octantValue * 0.00000000000000269515142907905952645d;
        var square = reduced * reduced;
        if (octant is 1 or 2)
        {
            var sinePolynomial = (((((
                0.000000000158962301576546568060d * square -
                0.0000000250507477628578072866d) * square +
                0.00000275573136213857245213d) * square -
                0.000198412698295895385996d) * square +
                0.00833333333332211858878d) * square -
                0.166666666666666307295d);
            return sign * (reduced + reduced * square * sinePolynomial);
        }
        var polynomial = (((((
            -0.0000000000113585365213876817300d * square +
            0.00000000208757008419747316778d) * square -
            0.000000275573141792967388112d) * square +
            0.0000248015872888517045348d) * square -
            0.00138888888888730564116d) * square +
            0.0416666666666665929218d);
        return sign * (1d - 0.5d * square + square * square * polynomial);
    }

    private static double DeterministicExponential(double value)
    {
        if (value > 709.782712893383973096d)
            return Math.PositiveInfinity;
        if (value < -745.13321910194110842d)
            return 0d;

        var exponentValue = Math.Floor(1.44269504088896340736d * value + 0.5d);
        var exponent = (int)exponentValue;
        var reduced = value - exponentValue * 0.693359375d;
        reduced -= exponentValue * -0.000212194440054690582768d;
        var square = reduced * reduced;
        var numerator = reduced * ((
            0.000126177193074810590878d * square + 0.03029944077074419613d) * square + 1d);
        var denominator = (((
            0.00000300198505138664455042d * square + 0.00252448340349684104192d) * square +
            0.227265548208155028766d) * square + 2d);
        var result = 1d + 2d * numerator / (denominator - numerator);
        return Math.ScaleB(result, exponent);
    }

    private static double DeterministicNaturalLogarithm(double value)
    {
        if (value == 0d)
            return Math.NegativeInfinity;
        if (value < 0d || Math.IsNaN(value))
            return Math.NaN;
        if (double.IsPositiveInfinity(value))
            return Math.PositiveInfinity;

        var exponent = Math.ILogB(value) + 1;
        var reduced = Math.ScaleB(value, -exponent);
        if (reduced < 0.70710678118654752440d)
        {
            exponent--;
            reduced = 2d * reduced - 1d;
        }
        else
        {
            reduced -= 1d;
        }

        var square = reduced * reduced;
        var numerator = (((((
            0.000101875663804580931796d * reduced + 0.497494994976747001425d) * reduced +
            4.70579119878881725854d) * reduced + 14.4989225341610930846d) * reduced +
            17.9368678507819816313d) * reduced + 7.70838733755885391666d);
        var denominator = (((((
            reduced + 11.2873587189167450590d) * reduced + 45.2279145837532221105d) * reduced +
            82.9875266912776603211d) * reduced + 71.1544750618563894466d) * reduced +
            23.1251620126765340583d);
        var correction = reduced * (square * numerator / denominator);
        correction -= exponent * 0.000212194440054690582768d;
        correction -= 0.5d * square;
        return reduced + correction + exponent * 0.693359375d;
    }

    private static double IntegerPower(double value, long exponent)
    {
        if (exponent == 0)
            return 1d;
        var negative = exponent < 0;
        var remaining = negative ? unchecked((ulong)(-(exponent + 1)) + 1ul) : (ulong)exponent;
        var powerBase = value;
        var result = 1d;
        while (remaining != 0ul)
        {
            if ((remaining & 1ul) != 0ul)
                result *= powerBase;
            remaining >>= 1;
            if (remaining != 0ul)
                powerBase *= powerBase;
        }
        return negative ? 1d / result : result;
    }
}

internal static partial class ScalarMathBlocks
{

    private static void AddDimensionlessUnary(
        ICollection<MathBlockOperation> operations,
        string identifier,
        Func<double, double> function,
        double sample,
        double expected) =>
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
