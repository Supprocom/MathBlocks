using Xunit.Abstractions;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies the hyperbolic sine and cosine stay finite up to |x| of about 89.415 (the exponential overflows at 88.72), that every result that was finite
/// is bit-identical, and the declared domain 0..34 of the factorial.
/// </summary>
public sealed class MathBlockHyperbolicOverflowTests(ITestOutputHelper output)
{
    private const float FullRangeFrom = 70f;
    private const float Upper = 88.8f;
    private const int Stride = 7;

    /// <summary>
    /// Verifies the hyperbolic sine is bit-identical to the old formula where that was finite: every float of +-[70, 88.8], and every 7th float of
    /// +-[0, 70] (every float would take several minutes).
    /// </summary>
    [Fact]
    public void HyperbolicSineIsBitIdenticalWhereTheFormulaWasFinite() =>
        VerifyBitIdentity("sinh", MathBlockTrigonometricOldOracle.HyperbolicSine, MathBlockScalar.HyperbolicSine);

    /// <summary>
    /// Verifies the hyperbolic cosine is bit-identical to the old formula where that was finite: every float of +-[70, 88.8], and every 7th float of
    /// +-[0, 70] (every float would take several minutes).
    /// </summary>
    [Fact]
    public void HyperbolicCosineIsBitIdenticalWhereTheFormulaWasFinite() =>
        VerifyBitIdentity("cosh", MathBlockTrigonometricOldOracle.HyperbolicCosine, MathBlockScalar.HyperbolicCosine);

    /// <summary>
    /// Verifies for every float of +-[88.7, 89.5] that the hyperbolic sine is within 4 * 2^-23 relative of Math.Sinh on the double where that is within
    /// float range, and is an infinity (invalid) where it is beyond.
    /// </summary>
    [Fact]
    public void HyperbolicSineIsAccurateAcrossTheOverflowEdge() =>
        VerifyEdgeAccuracy("sinh", MathBlockScalar.HyperbolicSine, Math.Sinh);

    /// <summary>
    /// Verifies for every float of +-[88.7, 89.5] that the hyperbolic cosine is within 4 * 2^-23 relative of Math.Cosh on the double where that is within
    /// float range, and is +infinity (invalid) where it is beyond.
    /// </summary>
    [Fact]
    public void HyperbolicCosineIsAccurateAcrossTheOverflowEdge() =>
        VerifyEdgeAccuracy("cosh", MathBlockScalar.HyperbolicCosine, Math.Cosh);

    /// <summary>Verifies NaN stays NaN, the infinities stay infinite and the signs are right beyond the old overflow.</summary>
    [Fact]
    public void HyperbolicSineAndCosineKeepNaNAndSignsAtTheEdges()
    {
        Assert.True(float.IsNaN(MathBlockScalar.HyperbolicSine(float.NaN)));
        Assert.True(float.IsNaN(MathBlockScalar.HyperbolicCosine(float.NaN)));
        Assert.Equal(float.PositiveInfinity, MathBlockScalar.HyperbolicSine(float.PositiveInfinity));
        Assert.Equal(float.NegativeInfinity, MathBlockScalar.HyperbolicSine(float.NegativeInfinity));
        Assert.Equal(float.PositiveInfinity, MathBlockScalar.HyperbolicCosine(float.NegativeInfinity));
        Assert.True(float.IsFinite(MathBlockScalar.HyperbolicSine(89f)) && MathBlockScalar.HyperbolicSine(89f) > 0f);
        Assert.True(float.IsFinite(MathBlockScalar.HyperbolicSine(-89f)) && MathBlockScalar.HyperbolicSine(-89f) < 0f);
        Assert.True(float.IsInfinity(MathBlockScalar.HyperbolicSine(89.5f)));
        Assert.True(float.IsInfinity(MathBlockScalar.HyperbolicCosine(89.5f)));
        Assert.True(float.IsInfinity(MathBlockScalar.HyperbolicCosine(1e30f)));
        Assert.Equal(BitConverter.SingleToInt32Bits(-0f), BitConverter.SingleToInt32Bits(MathBlockScalar.HyperbolicSine(-0f)));
    }

    /// <summary>Verifies 34! is finite and valid and 35! is invalid, on the scalar API, the scalar block and the elementwise form with its validity sibling.</summary>
    [Fact]
    public void FactorialOf34IsValidAndOf35IsInvalid()
    {
        Assert.True(float.IsFinite(MathBlockProbability.Factorial(34)));
        Assert.True(float.IsInfinity(MathBlockProbability.Factorial(35)));

        var single34 = Run("combinatorics.factorial@1", [MathBlockValue.Scalar(34f)]);
        Assert.True(single34.IsValid);
        Assert.Equal(MathBlockProbability.Factorial(34), single34.AsScalar());
        foreach (var invalid in new[] { 35f, 36f, 170f, 171f, -1f, 2.5f })
            Assert.False(Run("combinatorics.factorial@1", [MathBlockValue.Scalar(invalid)]).IsValid, $"{invalid} must be invalid");

        var rows = new[] { 0f, 1f, 33f, 34f, 35f, 170f, 171f, 5f };
        var form = Run("elementwise.combinatorics.factorial@1", [MathBlockValue.Vector(rows), MathBlockValue.Scalar(-777f)]);
        Assert.True(form.IsValid);
        var values = form.AsVector();
        Assert.Equal(MathBlockProbability.Factorial(34), values[3]);
        Assert.Equal(MathBlockProbability.Factorial(33), values[2]);
        Assert.Equal(120f, values[7]);
        foreach (var index in new[] { 4, 5, 6 })
            Assert.Equal(-777f, values[index]);

        var validity = Run("elementwise-valid.combinatorics.factorial@1", [MathBlockValue.Vector(rows)]).AsBooleanVector();
        Assert.Equal(new[] { true, true, true, true, false, false, false, true }, validity.ToArray());
    }

    private static MathBlockValue Run(string identity, IReadOnlyList<MathBlockValue> values)
    {
        var (program, inputs) = MathBlockCudaDomainDeviceTests.Build(identity, values);
        return MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"];
    }

    private void VerifyBitIdentity(string name, Func<float, float> old, Func<float, float> current)
    {
        long identical = 0;
        long rescued = 0;
        long skipped = 0;
        var stop = BitConverter.SingleToInt32Bits(Upper);
        var full = BitConverter.SingleToInt32Bits(FullRangeFrom);
        for (var bits = 0; bits <= stop; bits += bits < full ? Stride : 1)
        {
            var x = BitConverter.Int32BitsToSingle(bits);
            foreach (var value in new[] { x, -x })
            {
                var before = old(value);
                var after = current(value);
                if (float.IsFinite(before))
                {
                    Assert.Equal(BitConverter.SingleToInt32Bits(before), BitConverter.SingleToInt32Bits(after));
                    identical++;
                }
                else if (float.IsFinite(after))
                {
                    rescued++;
                }
                else
                {
                    skipped++;
                }
            }
        }

        Assert.True(identical > 0);
        output.WriteLine($"{name}: {identical} floats bit-identical where the old result was finite (every float of +-[70, {Upper}], every {Stride}th of +-[0, 70]); {rescued} newly finite; {skipped} still infinite.");
    }

    private void VerifyEdgeAccuracy(string name, Func<float, float> function, Func<double, double> reference)
    {
        var maxError = 0d;
        long finiteCount = 0;
        long infiniteCount = 0;
        var first = BitConverter.SingleToInt32Bits(88.7f);
        var last = BitConverter.SingleToInt32Bits(89.5f);
        for (var bits = first; bits <= last; bits++)
        {
            var x = BitConverter.Int32BitsToSingle(bits);
            foreach (var value in new[] { x, -x })
            {
                var expected = reference(value);
                var actual = function(value);
                if (Math.Abs(expected) <= float.MaxValue)
                {
                    Assert.True(float.IsFinite(actual), $"{name}({value:R}) must be finite");
                    var error = Math.Abs(actual - expected) / Math.Abs(expected);
                    maxError = Math.Max(maxError, error);
                    Assert.True(error <= 4 * Math.Pow(2, -23), $"{name}({value:R}) error {error:R}");
                    finiteCount++;
                }
                else
                {
                    Assert.True(float.IsInfinity(actual) && Math.Sign(actual) == Math.Sign(expected), $"{name}({value:R}) must be an infinity of the sign of {expected:R}");
                    infiniteCount++;
                }
            }
        }

        output.WriteLine($"{name}: {finiteCount} finite and {infiniteCount} infinite floats of +-[88.7, 89.5]; max relative error {maxError:R} = {maxError / Math.Pow(2, -23):F3} * 2^-23.");
    }
}
