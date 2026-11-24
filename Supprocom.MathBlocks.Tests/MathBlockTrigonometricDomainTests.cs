using System.Numerics;
using Xunit.Abstractions;
using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies sine, cosine and tangent on the domain |x| &lt;= 2^24: the constants of the reduction by quarter turns, the accuracy against the
/// double-precision library sine over every float from 2^20 to 2^24 and a million random floats, the NaN and invalid result beyond the bound, and
/// the agreement with the sine and cosine of 0.8.0-local.2 where that reduction was exact.
/// </summary>
public sealed class MathBlockTrigonometricDomainTests(ITestOutputHelper output)
{
    private const float Limit = 16_777_216f;
    private const double AbsoluteBound = 2.5e-7;

    // The library's literals (ScalarMathBlocks.cs), as the signed 12-bit integers and exponents that the derivation test reproduces.
    private static readonly (float Literal, int Mantissa, int Exponent)[] Pieces =
    [
        (1.5708008f, 3217, -11), (-4.4535846e-06f, -2391, -29), (-8.706138e-10f, -3829, -42), (6.2228e-14f, 1121, -54),
        (5.7208605e-18f, 3377, -69), (3.281839e-22f, 1587, -82), (1.6446172e-26f, 1303, -96)
    ];

    /// <summary>
    /// Derives the seven pieces of pi/2 from pi to 400 bits: each is the previous remainder rounded to 12 significant bits, so every product of a
    /// piece with a 12-bit half of the quarter-turn count is exact. Verifies the library's literals are those pieces and that 84 bits plus the
    /// leading bit leave less than 2^-100 of pi/2 out.
    /// </summary>
    [Fact]
    public void PiOverTwoPiecesAreDerivedExactlyAndHaveAtMostTwelveBits()
    {
        const int scale = 400;
        var one = BigInteger.One << scale;
        BigInteger ArctanInverse(int n)
        {
            var term = one / n;
            var total = term;
            var squared = (BigInteger)n * n;
            for (var k = 3; !term.IsZero; k += 2)
            {
                term /= squared;
                total += (k / 2 % 2 == 1 ? -1 : 1) * (term / k);
            }

            return total;
        }

        var pi = 4 * (4 * ArctanInverse(5) - ArctanInverse(239));
        var remainder = pi / 2;
        foreach (var (literal, mantissa, exponent) in Pieces)
        {
            var length = (int)(BigInteger.Abs(remainder).GetBitLength());
            // The unit of the last of 12 significant bits, relative to the 2^scale fixed point.
            var shift = length - 12;
            var half = BigInteger.One << (shift - 1);
            var rounded = remainder.Sign >= 0 ? (remainder + half) >> shift : -((-remainder + half) >> shift);
            Assert.True(BigInteger.Abs(rounded) < 4096);
            // A piece whose rounding ends in zero bits has fewer than 12 significant bits: compare the odd mantissa and its exponent.
            var oddMantissa = (int)rounded;
            var oddExponent = shift - scale;
            while (oddMantissa % 2 == 0)
            {
                oddMantissa /= 2;
                oddExponent++;
            }

            Assert.Equal(mantissa, oddMantissa);
            Assert.Equal(exponent, oddExponent);
            Assert.Equal(MathF.ScaleB(mantissa, exponent), literal);
            remainder -= rounded << shift;
        }

        Assert.True(BigInteger.Abs(remainder) < (BigInteger.One << (scale - 100)));
    }

    /// <summary>
    /// Verifies the absolute error against the double-precision sine and cosine of the same float is at most 2.5e-7 for every float from 2^20 to 2^24
    /// inclusive, both signs, and that the sine is odd and the cosine even bit for bit. Writes the maximum error and its argument.
    /// </summary>
    [Fact]
    public void SineAndCosineMatchTheReferenceAtEveryFloatFromTwoToTheTwentyToTwoToTheTwentyFour()
    {
        var stats = new Stats();
        var first = BitConverter.SingleToInt32Bits(1_048_576f);
        var last = BitConverter.SingleToInt32Bits(Limit);
        for (var bits = first; bits <= last; bits++)
        {
            var x = BitConverter.Int32BitsToSingle(bits);
            stats.Check(x);
            stats.Check(-x);
        }

        stats.Report(output, "every float in [2^20, 2^24], both signs");
        stats.AssertWithin();
    }

    /// <summary>Verifies the same bound on a million random floats whose exponents are spread uniformly up to 2^24, both signs.</summary>
    [Fact]
    public void SineAndCosineMatchTheReferenceOnRandomFloatsOverAllExponents()
    {
        var stats = new Stats();
        var random = new Random(20_261_124);
        for (var index = 0; index < 1_000_000; index++)
        {
            // Exponent field 1 (2^-126) to 151 (2^24).
            var exponent = random.Next(1, 152);
            var bits = (exponent << 23) | random.Next(0, 1 << 23);
            var x = BitConverter.Int32BitsToSingle(bits);
            if (x > Limit)
                x = Limit;
            stats.Check(random.Next(2) == 0 ? x : -x);
        }

        stats.Report(output, "10^6 random floats, exponents 2^-126 to 2^24");
        stats.AssertWithin();
    }

    /// <summary>
    /// Verifies the tangent against the double-precision tangent where |cos| is at least 1e-3, over every 7th float from 2^20 to 2^24 and 10^6 random
    /// floats: the relative error is reported in units of 2^-23 and bounded by the argument-reduction error over |cos| (the sine and the cosine each
    /// carry at most 2.5e-7 absolute), and the result is finite or NaN everywhere, NaN exactly where the cosine is zero or the argument is outside
    /// the domain.
    /// </summary>
    [Fact]
    public void TangentMatchesTheReferenceWhereTheCosineIsNotSmall()
    {
        var worstUnits = 0.0;
        var worstArgument = 0f;
        var worstBoundRatio = 0.0;
        var checkedCount = 0;
        var worstMidUnits = 0.0;
        void Check(float x)
        {
            var actual = MathBlockScalar.Tangent(x);
            Assert.False(float.IsInfinity(actual));
            var cosine = Math.Cos((double)x);
            if (Math.Abs(cosine) < 1e-3)
                return;
            var reference = Math.Tan((double)x);
            var units = Math.Abs(actual - reference) / Math.Abs(reference) / Math.Pow(2, -23);
            checkedCount++;
            // The sine and the cosine each have at most 2.5e-7 absolute error: the tangent's relative error is at most that over |sin| plus that over |cos|, plus its own rounding.
            var bound = 2.5e-7 * (1 / Math.Abs(Math.Sin((double)x)) + 1 / Math.Abs(cosine)) + 1.2e-7;
            worstBoundRatio = Math.Max(worstBoundRatio, units * Math.Pow(2, -23) / bound);
            if (Math.Abs(reference) is >= 0.25 and <= 4)
                worstMidUnits = Math.Max(worstMidUnits, units);
            if (units > worstUnits)
            {
                worstUnits = units;
                worstArgument = x;
            }
        }

        var first = BitConverter.SingleToInt32Bits(1_048_576f);
        var last = BitConverter.SingleToInt32Bits(Limit);
        for (var bits = first; bits <= last; bits += 7)
            Check(BitConverter.Int32BitsToSingle(bits));
        var random = new Random(20_261_125);
        for (var index = 0; index < 1_000_000; index++)
        {
            var exponent = random.Next(1, 152);
            var x = BitConverter.Int32BitsToSingle((exponent << 23) | random.Next(0, 1 << 23));
            Check(random.Next(2) == 0 ? Math.Min(x, Limit) : -Math.Min(x, Limit));
        }

        output.WriteLine($"tangent: {checkedCount} arguments with |cos| >= 1e-3; max relative error {worstUnits:F2} x 2^-23 at x={worstArgument:R}; worst ratio to the bound {worstBoundRatio:F3}; max relative error {worstMidUnits:F2} x 2^-23 where 0.25 <= |tan| <= 4.");
        Assert.True(worstBoundRatio <= 1.0, $"The tangent error exceeds the bound derived from the sine and cosine bounds (ratio {worstBoundRatio}).");
        Assert.True(float.IsNaN(MathBlockScalar.Tangent(Limit * 2f)));
    }

    /// <summary>Verifies 2^24 is valid and the next float is NaN, for sine, cosine and tangent and for the negatives; NaN, the infinities and the largest floats are NaN.</summary>
    [Fact]
    public void TheBoundIsInclusiveAndEverythingBeyondItIsNaN()
    {
        var beyond = float.BitIncrement(Limit);
        Assert.Equal(16_777_218f, beyond);
        foreach (var sign in new[] { 1f, -1f })
        {
            var inside = sign * Limit;
            var outside = sign * beyond;
            Assert.True(float.IsFinite(MathBlockScalar.Sine(inside)));
            Assert.True(float.IsFinite(MathBlockScalar.Cosine(inside)));
            Assert.True(float.IsFinite(MathBlockScalar.Tangent(inside)));
            Assert.True(float.IsNaN(MathBlockScalar.Sine(outside)));
            Assert.True(float.IsNaN(MathBlockScalar.Cosine(outside)));
            Assert.True(float.IsNaN(MathBlockScalar.Tangent(outside)));
            Assert.True(Math.Abs(Math.Sin(inside) - MathBlockScalar.Sine(inside)) <= AbsoluteBound);
            Assert.True(Math.Abs(Math.Cos(inside) - MathBlockScalar.Cosine(inside)) <= AbsoluteBound);
        }

        foreach (var value in new[]
                 {
                     float.NaN, float.PositiveInfinity, float.NegativeInfinity, float.MaxValue, -float.MaxValue, 1e30f, -1e30f, 1e9f, -1e9f,
                     1e7f * 3f, -1e7f * 3f
                 })
        {
            Assert.True(float.IsNaN(MathBlockScalar.Sine(value)), $"sine {value:R}");
            Assert.True(float.IsNaN(MathBlockScalar.Cosine(value)), $"cosine {value:R}");
            Assert.True(float.IsNaN(MathBlockScalar.Tangent(value)), $"tangent {value:R}");
        }

        // Signed zeros: the sine and the tangent of -0 are -0, of +0 are +0; the cosine is 1.
        Assert.Equal(BitConverter.SingleToInt32Bits(float.NegativeZero), BitConverter.SingleToInt32Bits(MathBlockScalar.Sine(float.NegativeZero)));
        Assert.Equal(BitConverter.SingleToInt32Bits(0f), BitConverter.SingleToInt32Bits(MathBlockScalar.Sine(0f)));
        Assert.Equal(BitConverter.SingleToInt32Bits(float.NegativeZero), BitConverter.SingleToInt32Bits(MathBlockScalar.Tangent(float.NegativeZero)));
        Assert.Equal(1f, MathBlockScalar.Cosine(float.NegativeZero));
        Assert.Equal(1f, MathBlockScalar.Cosine(0f));
    }

    /// <summary>
    /// Verifies the bound through the scalar operations, the elementwise forms with their per-row validity siblings, and the dispatch module's CoreCLR
    /// evaluation: 2^24 is valid, the next float, NaN, the infinities and the largest floats are invalid, and the same rows agree on every path.
    /// </summary>
    [Theory]
    [InlineData("sine")]
    [InlineData("cosine")]
    [InlineData("tangent")]
    public void TheBoundHoldsThroughTheOperationsTheFormsAndTheDispatchModule(string name)
    {
        var source = $"scalar.{name}";
        var rows = new[]
        {
            0.5f, -0.5f, Limit, -Limit, float.BitIncrement(Limit), -float.BitIncrement(Limit), float.NaN, float.PositiveInfinity,
            float.NegativeInfinity, float.MaxValue, -float.MaxValue, 1e9f, 16_777_215f, 3e7f
        };
        var expectedValid = new[] { true, true, true, true, false, false, false, false, false, false, false, false, true, false };
        var fill = MathBlockValue.Scalar(-777f);
        var operation = MathBlockCatalog.Standard.Get(source);
        var contract = Cuda.MathBlockCudaDeviceModule.GetOperation($"{source}@1");
        // A valid vector holds finite values only: NaN and the infinities reach the operations as invalid scalars, and every row as one of the finite rows.
        var finiteRows = rows.Where(float.IsFinite).ToArray();
        var finiteValid = expectedValid.Where((_, row) => float.IsFinite(rows[row])).ToArray();
        var form = Form(source).Evaluate(MathBlockValue.Vector(finiteRows), fill).AsVector().ToArray();
        var flags = Validity(source).Evaluate(MathBlockValue.Vector(finiteRows)).AsBooleanVector().ToArray();
        for (var row = 0; row < rows.Length; row++)
        {
            var scalar = operation.Evaluate(MathBlockValue.Scalar(rows[row]));
            var dispatched = contract.EvaluateCoreCLR(MathBlockValue.Scalar(rows[row]));
            Assert.Equal(expectedValid[row], scalar.IsValid);
            Assert.Equal(expectedValid[row], dispatched.IsValid);
            if (scalar.IsValid)
                Assert.Equal(BitConverter.SingleToInt32Bits(scalar.AsScalar()), BitConverter.SingleToInt32Bits(dispatched.AsScalar()));
        }

        for (var row = 0; row < finiteRows.Length; row++)
        {
            Assert.Equal(finiteValid[row], flags[row]);
            if (finiteValid[row])
                Assert.Equal(
                    BitConverter.SingleToInt32Bits(operation.Evaluate(MathBlockValue.Scalar(finiteRows[row])).AsScalar()),
                    BitConverter.SingleToInt32Bits(form[row]));
            else
                Assert.Equal(-777f, form[row]);
        }
    }

    /// <summary>
    /// Compares the new sine and cosine with those of 0.8.0-local.2 at every 7th positive float from 0 to 8192 (the sine is odd and the cosine even in
    /// both versions, so the negative half repeats it; every float would take about four minutes at nice 19, over the two-minute limit). Below 8192 the
    /// old reduction was exact, so the results differ only by rounding. Reports how many results differ and the largest difference.
    /// </summary>
    [Fact]
    public void ResultsInsideTheOldGoodRangeAgreeWithTheOldImplementationToRounding()
    {
        long total = 0;
        long sineDiffers = 0;
        long cosineDiffers = 0;
        double sineMax = 0;
        double cosineMax = 0;
        float sineAt = 0;
        float cosineAt = 0;
        var last = BitConverter.SingleToInt32Bits(8192f);
        for (var bits = 0; bits <= last; bits += 7)
        {
            var x = BitConverter.Int32BitsToSingle(bits);
            total++;
            var newSine = MathBlockScalar.Sine(x);
            var oldSine = MathBlockTrigonometricOldOracle.Sine(x);
            if (BitConverter.SingleToInt32Bits(newSine) != BitConverter.SingleToInt32Bits(oldSine))
            {
                sineDiffers++;
                var difference = Math.Abs((double)newSine - oldSine);
                if (difference > sineMax)
                {
                    sineMax = difference;
                    sineAt = x;
                }
            }

            var newCosine = MathBlockScalar.Cosine(x);
            var oldCosine = MathBlockTrigonometricOldOracle.Cosine(x);
            if (BitConverter.SingleToInt32Bits(newCosine) != BitConverter.SingleToInt32Bits(oldCosine))
            {
                cosineDiffers++;
                var difference = Math.Abs((double)newCosine - oldCosine);
                if (difference > cosineMax)
                {
                    cosineMax = difference;
                    cosineAt = x;
                }
            }
        }

        output.WriteLine($"old vs new over {total} floats of [0, 8192] (every 7th): sine differs {sineDiffers} (max {sineMax:E3} at {sineAt:R}), cosine differs {cosineDiffers} (max {cosineMax:E3} at {cosineAt:R}).");
        Assert.True(sineMax <= 3e-7, $"sine max difference {sineMax}");
        Assert.True(cosineMax <= 3e-7, $"cosine max difference {cosineMax}");
    }

    private sealed class Stats
    {
        private double sineMax;
        private double cosineMax;
        private float sineAt;
        private float cosineAt;
        private long count;

        public void Check(float x)
        {
            count++;
            var sine = MathBlockScalar.Sine(x);
            var cosine = MathBlockScalar.Cosine(x);
            var sineError = Math.Abs(sine - Math.Sin((double)x));
            var cosineError = Math.Abs(cosine - Math.Cos((double)x));
            if (sineError > sineMax)
            {
                sineMax = sineError;
                sineAt = x;
            }

            if (cosineError > cosineMax)
            {
                cosineMax = cosineError;
                cosineAt = x;
            }

            // The sine is odd and the cosine even bit for bit.
            if (BitConverter.SingleToInt32Bits(MathBlockScalar.Sine(-x)) != BitConverter.SingleToInt32Bits(-sine) && x != 0f)
                throw new InvalidOperationException($"sine is not odd at {x:R}");
            if (BitConverter.SingleToInt32Bits(MathBlockScalar.Cosine(-x)) != BitConverter.SingleToInt32Bits(cosine))
                throw new InvalidOperationException($"cosine is not even at {x:R}");
        }

        public void Report(ITestOutputHelper output, string label) =>
            output.WriteLine($"{label}: {count} arguments; max sine error {sineMax:E3} at x={sineAt:R}; max cosine error {cosineMax:E3} at x={cosineAt:R}.");

        public void AssertWithin()
        {
            Assert.True(sineMax <= AbsoluteBound, $"sine error {sineMax:E3} at {sineAt:R}");
            Assert.True(cosineMax <= AbsoluteBound, $"cosine error {cosineMax:E3} at {cosineAt:R}");
        }
    }
}
