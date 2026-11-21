using System.Numerics;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies the owned square root is correctly rounded, as IEEE 754 requires: each result r of a positive finite x
/// lies within half a unit in the last place of the exact square root, that is, the squares of the midpoints
/// between r and its neighbours bracket x. The midpoints and their squares are exact BigInteger values.
/// </summary>
public sealed class MathBlockSquareRootTests
{
    /// <summary>Verifies seeded inputs across the normal and subnormal range give correctly rounded results.</summary>
    [Fact]
    public void SquareRootIsCorrectlyRounded()
    {
        var random = new Random(20261101);
        var failures = new SortedSet<float>();
        var count = 0;
        foreach (var value in Inputs(random))
        {
            count++;
            if (!IsCorrectlyRounded(value, MathBlockScalar.SquareRoot(value)))
                failures.Add(value);
        }

        Assert.True(count > 100_000, $"Only {count} inputs were generated.");
        Assert.True(
            failures.Count == 0,
            $"{failures.Count} of {count} inputs are not correctly rounded; first 10:{Environment.NewLine}" +
            string.Join(Environment.NewLine, failures.Take(10).Select(value =>
                $"sqrt({value:R}) = {MathBlockScalar.SquareRoot(value):R} (0x{BitConverter.DoubleToInt64Bits(MathBlockScalar.SquareRoot(value)):X16})")));
    }

    /// <summary>Verifies the special values keep their results.</summary>
    [Theory]
    [InlineData(0f, 0x0000000000000000L)]
    [InlineData(-0f, unchecked((long)0x8000000000000000UL))]
    [InlineData(float.PositiveInfinity, 0x7FF0000000000000L)]
    [InlineData(4f, 0x4000000000000000L)]
    public void SpecialValuesKeepTheirResults(float value, long expectedBits) =>
        Assert.Equal(expectedBits, BitConverter.SingleToInt32Bits(MathBlockScalar.SquareRoot(value)));

    private static IEnumerable<float> Inputs(Random random)
    {
        // Uniform significands at every exponent, including subnormals, and values next to perfect squares.
        for (var exponent = -1074; exponent <= 1023; exponent += 7)
            for (var sample = 0; sample < 300; sample++)
            {
                var value = MathF.ScaleB(1f + random.NextSingle(), exponent);
                if (float.IsFinite(value) && value > 0f)
                    yield return value;
            }
        for (var root = 1; root < 20_000; root++)
        {
            var square = (float)root * root;
            yield return MathF.BitDecrement(square);
            yield return MathF.BitIncrement(square);
        }
    }

    private static bool IsCorrectlyRounded(float value, float result)
    {
        if (!float.IsFinite(result) || result <= 0f)
            return false;
        var x = Exact(value);
        var below = Square(Midpoint(Exact(MathF.BitDecrement(result)), Exact(result)));
        var above = Square(Midpoint(Exact(result), Exact(MathF.BitIncrement(result))));
        var lower = Compare(below, x);
        var upper = Compare(x, above);
        if (lower < 0 && upper < 0)
            return true;
        // A tie goes to the even significand.
        var even = (BitConverter.SingleToInt32Bits(result) & 1) == 0;
        return even && lower <= 0 && upper <= 0;
    }

    // value = Mantissa * 2^Exponent exactly.
    private static (BigInteger Mantissa, int Exponent) Exact(float value)
    {
        var bits = BitConverter.SingleToInt32Bits(value);
        var exponent = (int)((bits >> 52) & 0x7FF);
        var fraction = bits & 0xFFFFFFFFFFFFFL;
        return exponent == 0
            ? (fraction, -1074)
            : (fraction | (1L << 52), exponent - 1075);
    }

    private static (BigInteger Mantissa, int Exponent) Midpoint((BigInteger Mantissa, int Exponent) left, (BigInteger Mantissa, int Exponent) right)
    {
        var exponent = Math.Min(left.Exponent, right.Exponent);
        var sum = (left.Mantissa << (left.Exponent - exponent)) + (right.Mantissa << (right.Exponent - exponent));
        return (sum, exponent - 1);
    }

    private static (BigInteger Mantissa, int Exponent) Square((BigInteger Mantissa, int Exponent) value) =>
        (value.Mantissa * value.Mantissa, value.Exponent * 2);

    private static int Compare((BigInteger Mantissa, int Exponent) left, (BigInteger Mantissa, int Exponent) right)
    {
        var exponent = Math.Min(left.Exponent, right.Exponent);
        return (left.Mantissa << (left.Exponent - exponent)).CompareTo(right.Mantissa << (right.Exponent - exponent));
    }
}
