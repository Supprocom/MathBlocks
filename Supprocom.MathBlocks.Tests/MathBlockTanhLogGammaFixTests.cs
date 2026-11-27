using Xunit.Abstractions;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies the two guards of 0.8.0: the hyperbolic tangent is +-1 beyond 20 where the quotient of the exponentials was infinity over infinity, and
/// the reflection of the log-gamma takes the absolute value of the sine, so the negative non-integers have a value.
/// </summary>
public sealed class MathBlockTanhLogGammaFixTests(ITestOutputHelper output)
{
    /// <summary>
    /// Verifies the hyperbolic tangent is bit-identical to the unguarded formula for every float in [9, 88.7] and its negative (where the formula
    /// already gives exactly +-1 beyond 20), and wherever the unguarded formula is finite for 2^22 random floats.
    /// </summary>
    [Fact]
    public void HyperbolicTangentIsBitIdenticalWhereTheFormulaWasFinite()
    {
        long checkedCount = 0;
        var first = BitConverter.SingleToInt32Bits(9f);
        var last = BitConverter.SingleToInt32Bits(88.7f);
        for (var bits = first; bits <= last; bits++)
        {
            var x = BitConverter.Int32BitsToSingle(bits);
            foreach (var value in new[] { x, -x })
            {
                var old = MathBlockTrigonometricOldOracle.HyperbolicTangent(value);
                Assert.True(float.IsFinite(old), $"the formula is not finite at {value:R}");
                Assert.Equal(BitConverter.SingleToInt32Bits(old), BitConverter.SingleToInt32Bits(MathBlockScalar.HyperbolicTangent(value)));
                checkedCount++;
            }
        }

        var random = new Random(20_261_126);
        var finiteOld = 0;
        for (var index = 0; index < 1 << 22; index++)
        {
            var value = BitConverter.Int32BitsToSingle(random.Next(int.MinValue, 0x7f80_0000) ^ (random.Next(2) << 31));
            if (!float.IsFinite(value))
                continue;
            var old = MathBlockTrigonometricOldOracle.HyperbolicTangent(value);
            var actual = MathBlockScalar.HyperbolicTangent(value);
            if (float.IsFinite(old))
            {
                Assert.Equal(BitConverter.SingleToInt32Bits(old), BitConverter.SingleToInt32Bits(actual));
                finiteOld++;
            }
            else
            {
                Assert.Equal(value < 0f ? -1f : 1f, actual);
            }
        }

        output.WriteLine($"tanh: {checkedCount} floats of +-[9, 88.7] identical; {finiteOld} random floats identical where the formula was finite.");
    }

    /// <summary>Verifies the hyperbolic tangent is exactly +1 and -1 from 88.72 (where the exponential overflows) to the largest float and at the infinities, and NaN stays NaN.</summary>
    [Fact]
    public void HyperbolicTangentIsPlusOrMinusOneWhereTheExponentialsOverflow()
    {
        foreach (var value in new[] { 88.72284f, 88.73f, 89f, 104f, 1e5f, 1e20f, float.MaxValue })
        {
            Assert.Equal(1f, MathBlockScalar.HyperbolicTangent(value));
            Assert.Equal(-1f, MathBlockScalar.HyperbolicTangent(-value));
        }

        Assert.True(float.IsNaN(MathBlockTrigonometricOldOracle.HyperbolicTangent(89f)));
        Assert.True(float.IsNaN(MathBlockTrigonometricOldOracle.HyperbolicTangent(-104.5f)));
        Assert.Equal(1f, MathBlockScalar.HyperbolicTangent(20.000002f));
        Assert.Equal(1f, MathBlockScalar.HyperbolicTangent(float.PositiveInfinity));
        Assert.Equal(-1f, MathBlockScalar.HyperbolicTangent(float.NegativeInfinity));
        Assert.True(float.IsNaN(MathBlockScalar.HyperbolicTangent(float.NaN)));
        Assert.Equal(1f, MathBlockCatalog.Standard.Get("scalar.hyperbolic-tangent").Evaluate(MathBlockValue.Scalar(1000f)).AsScalar());
        var form = MathBlockElementwiseTestSupport.Form("scalar.hyperbolic-tangent")
            .Evaluate(MathBlockValue.Vector([1000f, -1000f, 0.5f]), MathBlockValue.Scalar(-777f)).AsVector().ToArray();
        Assert.Equal(1f, form[0]);
        Assert.Equal(-1f, form[1]);
    }

    /// <summary>
    /// Verifies the reflection branch is bit-identical to the old formula over every 1009th float of (0, 0.5), where the sine is positive and the absolute
    /// value changes nothing, and that the negative non-integers of the intervals (-10, 0) now have a finite value that matches the recurrence
    /// log|G(x)| = log|G(x + 1)| - log|x| (checked at least 0.02 from the poles, where the rounding of pi times x dominates), and that the poles stay invalid.
    /// </summary>
    [Fact]
    public void LogGammaReflectionIsUnchangedBelowOneHalfAndFiniteOnTheNegativeIntervals()
    {
        var first = BitConverter.SingleToInt32Bits(float.Epsilon);
        var last = BitConverter.SingleToInt32Bits(0.49999997f);
        long identical = 0;
        for (var bits = first; bits <= last; bits += 1_009)
        {
            var x = BitConverter.Int32BitsToSingle(bits);
            var old = MathBlockScalar.NaturalLogarithm(MathF.PI) - MathBlockScalar.NaturalLogarithm(MathBlockScalar.Sine(MathF.PI * x)) -
                      MathBlockProbability.LogGamma(1f - x);
            if (!float.IsFinite(old))
                continue;
            Assert.Equal(BitConverter.SingleToInt32Bits(old), BitConverter.SingleToInt32Bits(MathBlockProbability.LogGamma(x)));
            identical++;
        }

        long finite = 0;
        long compared = 0;
        var worst = 0.0;
        for (var interval = 0; interval < 10; interval++)
        {
            var from = BitConverter.SingleToInt32Bits((float)interval);
            var to = BitConverter.SingleToInt32Bits(interval + 1f);
            var step = 2_003;
            for (var bits = from + 1; bits < to; bits += step)
            {
                var x = -BitConverter.Int32BitsToSingle(bits);
                var actual = MathBlockProbability.LogGamma(x);
                Assert.True(float.IsFinite(actual), $"log-gamma({x:R}) is not finite");
                finite++;
                var distance = Math.Min(Math.Abs(x - Math.Round(x, MidpointRounding.ToEven)), 1.0);
                var shifted = x + 1f;
                if (distance < 0.02 || (shifted <= 0f && shifted == MathF.Floor(shifted)))
                    continue;
                var reference = MathBlockProbability.LogGamma(shifted) - Math.Log(Math.Abs((double)x));
                var error = Math.Abs(actual - reference) / (1.0 + Math.Abs(reference));
                worst = Math.Max(worst, error);
                compared++;
            }
        }

        output.WriteLine($"log-gamma: {identical} reflections identical to the old formula; {finite} negative non-integers finite, {compared} compared with the recurrence, worst relative difference {worst:E2}.");
        Assert.True(worst < 5e-4, $"recurrence difference {worst}");
        Assert.True(Math.Abs(MathBlockProbability.LogGamma(-0.5f) - 1.2655121) < 1e-4);
        Assert.True(Math.Abs(MathBlockProbability.LogGamma(-1.5f) - 0.8600470) < 1e-4);

        // The poles stay invalid.
        foreach (var pole in new[] { 0f, -0f, -1f, -2f, -3f, -100f, -8_388_608f })
            Assert.True(float.IsNaN(MathBlockProbability.LogGamma(pole)), $"pole {pole}");
        Assert.False(MathBlockCatalog.Standard.Get("special.log-gamma").Evaluate(MathBlockValue.Scalar(-2f)).IsValid);
        Assert.True(MathBlockCatalog.Standard.Get("special.log-gamma").Evaluate(MathBlockValue.Scalar(-2.5f)).IsValid);
    }
}
