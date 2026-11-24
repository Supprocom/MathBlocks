namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// The sine and cosine of 0.8.0-local.2, kept as a test-only oracle: the reduction by octants with the three-part quarter of pi, which is exact
/// only while the octant count is below about 2^13 and loses every digit well before 1e9. Inside that range the new reduction by quarter turns
/// is compared with it. The hyperbolic tangent of the same version is here too.
/// </summary>
internal static class MathBlockTrigonometricOldOracle
{
    internal static float Sine(float value)
    {
        if (value == 0f)
            return value;
        var sign = 1f;
        var x = value;
        if (x < 0f)
        {
            sign = -1f;
            x = -x;
        }
        var octantValue = MathF.Floor(x / 0.78539816339744830962f);
        var octant = (int)(octantValue - MathF.Floor(octantValue * 0.125f) * 8f);
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

    internal static float Cosine(float value)
    {
        var x = MathF.Abs(value);
        var sign = 1f;
        var octantValue = MathF.Floor(x / 0.78539816339744830962f);
        var octant = (int)(octantValue - MathF.Floor(octantValue * 0.125f) * 8f);
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

    internal static float Tangent(float value) => Sine(value) / Cosine(value);

    /// <summary>The hyperbolic tangent without the guard beyond 20.</summary>
    internal static float HyperbolicTangent(float value)
    {
        if (value == 0f)
            return value;
        var positive = MathBlockScalar.Exponential(value);
        var negative = MathBlockScalar.Exponential(-value);
        return (positive - negative) / (positive + negative);
    }
}
