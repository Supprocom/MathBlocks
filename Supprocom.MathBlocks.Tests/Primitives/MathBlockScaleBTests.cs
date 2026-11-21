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
        .GetMethod("ScaleB", BindingFlags.Public | BindingFlags.Static, [typeof(float), typeof(int)])!;

    private static readonly MethodInfo ReduceExponentialMethod = typeof(MathBlockScalar)
        .GetMethod("ReduceExponential", BindingFlags.NonPublic | BindingFlags.Static)!;

    /// <summary>Gets (value, exponent, expected bits) cases at the subnormal boundaries and at exact ties.</summary>
    public static TheoryData<float, int, int> BoundaryAndTieCases => new()
    {
        // 2^-126, the smallest normal, and 2^-149, the smallest subnormal.
        { 1f, -126, 0x0080_0000 },
        { 1f, -149, 1 },
        // Half the smallest subnormal ties between 0 and 2^-149 and goes to the even 0; above half rounds up.
        { 1f, -150, 0 },
        { 1.5f, -150, 1 },
        { -1f, -150, int.MinValue },
        // (2^24 - 1) / 2 units of 2^-149 ties between 2^23 - 1 and 2^23 and goes to 2^23, the smallest normal.
        { 1f - 1f / 16_777_216f, -126, 0x0080_0000 },
        // q + 1/2 units of 2^-149 go to the even neighbour.
        { 1.5f, -149, 2 },
        { 2.5f, -149, 2 },
        { 3.5f, -149, 4 },
        { 0.5f, -149, 0 },
        { 5f, -150, 2 },
        { 7f, -150, 4 },
        // 0.75 + 2^-24 at 2^-127 is 3 * 2^20 + 1/4 units: it rounds down.
        { 0.75f + 1f / 16_777_216f, -127, 0x0030_0000 },
        // 0.5 + 5 * 2^-24 at 2^-128 is 2^20 + 5/8 units and rounds up. Scaling by 2^-126 first rounds 2^22 + 5/2
        // units to 2^22 + 2, and the second scaling then ties back down to 2^20: two roundings give the wrong bit.
        { 0.5f + 5f / 16_777_216f, -128, 0x0010_0001 },
        // Normal results stay exact.
        { 1.25f, 10, 0x44A0_0000 },
        { float.Epsilon, 149, 0x3F80_0000 }
    };

    /// <summary>Verifies ScaleB at the subnormal boundaries and at exact ties, against fixed bits and the reference.</summary>
    [Theory]
    [MemberData(nameof(BoundaryAndTieCases))]
    public void ScaleBRoundsOnceAtSubnormalBoundariesAndTies(float value, int exponent, int expectedBits)
    {
        Assert.Equal(expectedBits, BitConverter.SingleToInt32Bits(Reference(value, exponent)));
        Assert.Equal(expectedBits, BitConverter.SingleToInt32Bits(ScaleB(value, exponent)));
    }

    /// <summary>
    /// Verifies ScaleB against the exact reference on 60,000 seeded cases: significands in [0.5, 2) of both signs
    /// scaled into the subnormal range and across the 2^-126 boundary, and into the normal range.
    /// </summary>
    [Fact]
    public void ScaleBMatchesTheExactReferenceOnSeededCases()
    {
        var random = new Random(1_074);
        var failures = new List<string>();
        var subnormal = 0;
        for (var index = 0; index < 60_000; index++)
        {
            var value = (random.NextSingle() * 1.5f + 0.5f) * (random.Next(2) == 0 ? 1f : -1f);
            var exponent = index % 3 == 2 ? random.Next(-120, 120) : random.Next(-155, -119);
            var expected = Reference(value, exponent);
            var actual = ScaleB(value, exponent);
            if (expected != 0f && Math.Abs(expected) < 1.1754943e-38f)
                subnormal++;
            if (BitConverter.SingleToInt32Bits(expected) != BitConverter.SingleToInt32Bits(actual) && failures.Count < 20)
                failures.Add($"ScaleB({value:R}, {exponent}) = 0x{BitConverter.SingleToInt32Bits(actual):X8}, exact 0x{BitConverter.SingleToInt32Bits(expected):X8}");
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
        Assert.True(subnormal > 20_000, $"Only {subnormal} subnormal results.");
    }

    /// <summary>
    /// Verifies the exponential rounds its final scaling once on 20,000 non-dyadic points of (-103.9, -87.3), where
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
            var x = -103.9f + 16.6f * ((index + 0.1f) / 20_000f);
            object?[] arguments = [x, 0];
            var reduced = (float)ReduceExponentialMethod.Invoke(null, arguments)!;
            var expected = Reference(reduced, (int)arguments[1]!);
            var actual = MathBlockScalar.Exponential(x);
            if (expected != 0f && expected < 1.1754943e-38f)
                subnormal++;
            if (BitConverter.SingleToInt32Bits(expected) != BitConverter.SingleToInt32Bits(actual) && failures.Count < 20)
                failures.Add($"exp({x:R}) = 0x{BitConverter.SingleToInt32Bits(actual):X8}, exact scaling 0x{BitConverter.SingleToInt32Bits(expected):X8}");
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
        Assert.True(subnormal > 19_000, $"Only {subnormal} subnormal results.");
    }

    private static float ScaleB(float value, int exponent) => (float)ScaleBMethod.Invoke(null, [value, exponent])!;

    // value * 2^exponent rounded to nearest, ties to even, from the exact significand and exponent.
    private static float Reference(float value, int exponent)
    {
        var bits = BitConverter.SingleToInt32Bits(value);
        var negative = bits < 0;
        var biased = (bits >> 23) & 0xff;
        var fraction = bits & 0x007F_FFFF;
        BigInteger significand = biased == 0 ? fraction : fraction | (1 << 23);
        var scale = (biased == 0 ? -149 : biased - 150) + exponent;
        if (significand.IsZero)
            return value;
        // Keep 24 significant bits, or fewer where the result falls below 2^-126 (its last bit is 2^-149).
        var length = (int)significand.GetBitLength();
        var shift = Math.Max(length - 24, -149 - scale);
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
        if (quotient.GetBitLength() > 24)
        {
            quotient >>= 1;
            lsb++;
        }
        int resultBits;
        if (quotient.GetBitLength() < 24)
        {
            // Subnormal (lsb is -149), or exactly 2^23 units, which is the smallest normal's encoding.
            resultBits = (int)(quotient << (lsb + 149));
        }
        else
        {
            var resultBiased = lsb + 150;
            resultBits = (resultBiased << 23) | ((int)quotient & 0x007F_FFFF);
        }
        return BitConverter.Int32BitsToSingle(negative ? resultBits | int.MinValue : resultBits);
    }
}
