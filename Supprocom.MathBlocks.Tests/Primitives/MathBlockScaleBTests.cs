using System.Numerics;
using System.Reflection;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies the owned binary scaling rounds once, as IEEE 754 scaleB does: every result, including a subnormal
/// one, is the exact product value * 2^exponent rounded to nearest with ties to even. The reference rounds the
/// exact product with BigInteger arithmetic.
/// </summary>
public sealed class MathBlockScaleBTests
{
    private static readonly MethodInfo ScaleBMethod = typeof(MathBlockScalar).Assembly
        .GetType("Supprocom.MathBlocks.MathBlockPrimitives", throwOnError: true)!
        .GetMethod("ScaleB", BindingFlags.Public | BindingFlags.Static, [typeof(double), typeof(int)])!;

    private static readonly MethodInfo ReduceExponentialMethod = typeof(MathBlockScalar)
        .GetMethod("ReduceExponential", BindingFlags.NonPublic | BindingFlags.Static)!;

    /// <summary>Gets (value, exponent, expected bits) cases at the subnormal boundaries and at exact ties.</summary>
    public static TheoryData<double, int, long> BoundaryAndTieCases => new()
    {
        // 2^-1022, the smallest normal, and 2^-1074, the smallest subnormal.
        { 1d, -1022, 0x0010_0000_0000_0000L },
        { 1d, -1074, 1L },
        // Half the smallest subnormal ties between 0 and 2^-1074 and goes to the even 0; above half rounds up.
        { 1d, -1075, 0L },
        { 1.5d, -1075, 1L },
        { -1d, -1075, long.MinValue },
        // (2^53 - 1) / 2 units of 2^-1074 ties between 2^52 - 1 and 2^52 and goes to 2^52, the smallest normal.
        { 1d - 1d / 9_007_199_254_740_992d, -1022, 0x0010_0000_0000_0000L },
        // q + 1/2 units of 2^-1074 go to the even neighbour.
        { 1.5d, -1074, 2L },
        { 2.5d, -1074, 2L },
        { 3.5d, -1074, 4L },
        { 0.5d, -1074, 0L },
        { 5d, -1075, 2L },
        { 7d, -1075, 4L },
        // 0.75 + 2^-53 at 2^-1023 is 3 * 2^49 + 1/4 units: it rounds down.
        { 0.75d + 1d / 9_007_199_254_740_992d, -1023, 0x0006_0000_0000_0000L },
        // 0.5 + 5 * 2^-53 at 2^-1024 is 2^49 + 5/8 units and rounds up. Scaling by 2^-1022 first rounds 2^51 + 5/2
        // units to 2^51 + 2, and the second scaling then ties back down to 2^49: two roundings give the wrong bit.
        { 0.5d + 5d / 9_007_199_254_740_992d, -1024, 0x0002_0000_0000_0001L },
        // Normal results stay exact.
        { 1.25d, 10, 0x4094_0000_0000_0000L },
        { double.Epsilon, 1074, 0x3FF0_0000_0000_0000L }
    };

    /// <summary>Verifies ScaleB at the subnormal boundaries and at exact ties, against fixed bits and the reference.</summary>
    [Theory]
    [MemberData(nameof(BoundaryAndTieCases))]
    public void ScaleBRoundsOnceAtSubnormalBoundariesAndTies(double value, int exponent, long expectedBits)
    {
        Assert.Equal(expectedBits, BitConverter.DoubleToInt64Bits(Reference(value, exponent)));
        Assert.Equal(expectedBits, BitConverter.DoubleToInt64Bits(ScaleB(value, exponent)));
    }

    /// <summary>
    /// Verifies ScaleB against the exact reference on 60,000 seeded cases: significands in [0.5, 2) of both signs
    /// scaled into the subnormal range and across the 2^-1022 boundary, and into the normal range.
    /// </summary>
    [Fact]
    public void ScaleBMatchesTheExactReferenceOnSeededCases()
    {
        var random = new Random(1_074);
        var failures = new List<string>();
        var subnormal = 0;
        for (var index = 0; index < 60_000; index++)
        {
            var value = (random.NextDouble() * 1.5d + 0.5d) * (random.Next(2) == 0 ? 1d : -1d);
            var exponent = index % 3 == 2 ? random.Next(-1000, 1000) : random.Next(-1080, -1015);
            var expected = Reference(value, exponent);
            var actual = ScaleB(value, exponent);
            if (expected != 0d && Math.Abs(expected) < 2.2250738585072014E-308d)
                subnormal++;
            if (BitConverter.DoubleToInt64Bits(expected) != BitConverter.DoubleToInt64Bits(actual) && failures.Count < 20)
                failures.Add($"ScaleB({value:R}, {exponent}) = 0x{BitConverter.DoubleToInt64Bits(actual):X16}, exact 0x{BitConverter.DoubleToInt64Bits(expected):X16}");
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
        Assert.True(subnormal > 20_000, $"Only {subnormal} subnormal results.");
    }

    /// <summary>
    /// Verifies the exponential rounds its final scaling once on 20,000 non-dyadic points of (-745.1, -707.6), where
    /// the result is mostly subnormal: exp(x) equals the exact product of the reduced value and 2^exponent, rounded
    /// to nearest even.
    /// </summary>
    [Fact]
    public void ExponentialRoundsSubnormalResultsOnce()
    {
        var failures = new List<string>();
        var subnormal = 0;
        for (var index = 0; index < 20_000; index++)
        {
            var x = -745.1d + 37.5d * ((index + 0.1d) / 20_000d);
            object?[] arguments = [x, 0];
            var reduced = (double)ReduceExponentialMethod.Invoke(null, arguments)!;
            var expected = Reference(reduced, (int)arguments[1]!);
            var actual = MathBlockScalar.Exponential(x);
            if (expected != 0d && expected < 2.2250738585072014E-308d)
                subnormal++;
            if (BitConverter.DoubleToInt64Bits(expected) != BitConverter.DoubleToInt64Bits(actual) && failures.Count < 20)
                failures.Add($"exp({x:R}) = 0x{BitConverter.DoubleToInt64Bits(actual):X16}, exact scaling 0x{BitConverter.DoubleToInt64Bits(expected):X16}");
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
        Assert.True(subnormal > 19_000, $"Only {subnormal} subnormal results.");
    }

    private static double ScaleB(double value, int exponent) => (double)ScaleBMethod.Invoke(null, [value, exponent])!;

    // value * 2^exponent rounded to nearest, ties to even, from the exact significand and exponent.
    private static double Reference(double value, int exponent)
    {
        var bits = BitConverter.DoubleToInt64Bits(value);
        var negative = bits < 0;
        var biased = (int)((bits >> 52) & 0x7ff);
        var fraction = bits & 0x000F_FFFF_FFFF_FFFFL;
        BigInteger significand = biased == 0 ? fraction : fraction | (1L << 52);
        var scale = (biased == 0 ? -1074 : biased - 1075) + exponent;
        if (significand.IsZero)
            return value;
        // Keep 53 significant bits, or fewer where the result falls below 2^-1022 (its last bit is 2^-1074).
        var length = (int)significand.GetBitLength();
        var shift = Math.Max(length - 53, -1074 - scale);
        BigInteger quotient;
        if (shift > 0)
        {
            quotient = BigInteger.DivRem(significand, BigInteger.One << shift, out var remainder);
            var twice = remainder << 1;
            var divisor = BigInteger.One << shift;
            if (twice > divisor || (twice == divisor && !quotient.IsEven))
                quotient += 1;
        }
        else
        {
            quotient = significand << -shift;
        }
        var lsb = scale + shift;
        if (quotient.GetBitLength() > 53)
        {
            quotient >>= 1;
            lsb++;
        }
        long resultBits;
        if (quotient.GetBitLength() < 53)
        {
            // Subnormal (lsb is -1074), or exactly 2^52 units, which is the smallest normal's encoding.
            resultBits = (long)(quotient << (lsb + 1074));
        }
        else
        {
            var resultBiased = lsb + 52 + 1075 - 52;
            resultBits = ((long)(resultBiased) << 52) | ((long)quotient & 0x000F_FFFF_FFFF_FFFFL);
        }
        return BitConverter.Int64BitsToDouble(negative ? resultBits | long.MinValue : resultBits);
    }
}
