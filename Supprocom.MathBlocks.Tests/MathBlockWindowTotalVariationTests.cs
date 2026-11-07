using static Supprocom.MathBlocks.Tests.MathBlockWindowM2TestSupport;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the window.path.total-variation rows against the direct lift of the source, bit for bit.</summary>
public sealed class MathBlockWindowTotalVariationTests
{
    private const string Source = "path.total-variation";
    private const double Sentinel = 777.25d;

    private static readonly int[] Widths = [1, 2, 3, 5, 24, 96];

    private static void AssertSame(MathBlockValue[] inputs)
    {
        Assert.Null(Difference(DirectForm(Source).Evaluate(inputs), Form(Source).Evaluate(inputs)));
        Assert.Null(Difference(
            DirectValidity(Source).Evaluate(inputs[..^1]),
            Validity(Source).Evaluate(inputs[..^1])));
    }

    private static MathBlockValue[] Inputs(MathBlockValue series, int width) =>
        [series, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel)];

    /// <summary>Verifies random series, signed zeros and overflowing windows give the direct lift's rows and validity.</summary>
    [Fact]
    public void RowsAndValidityEqualTheDirectLiftBitForBit()
    {
        var random = new Random(20_261_107);
        foreach (var length in new[] { 1, 2, 3, 24, 97, 1_000 })
        {
            var plain = Enumerable.Range(0, length).Select(_ => (random.NextDouble() - 0.5d) * 10d).ToArray();
            var zeros = Enumerable.Range(0, length).Select(row => row % 3 == 0 ? -0d : row % 3 == 1 ? 0d : 1e-320d).ToArray();
            // Alternating extremes: every window of two or more rows sums to infinity, a lone big step overflows later.
            var extremes = Enumerable.Range(0, length).Select(row => row % 2 == 0 ? 1.7e308d : -1.7e308d).ToArray();
            var mixed = Enumerable.Range(0, length).Select(row => row % 40 == 39 ? 1.7e308d * (row % 80 == 39 ? 1d : -1d) : 1d).ToArray();
            foreach (var series in new[] { plain, zeros, extremes, mixed })
                foreach (var width in Widths.Where(width => width <= length))
                    AssertSame(Inputs(MathBlockValue.Vector(series), width));
        }
    }

    /// <summary>Verifies widths 1 and 2: a one-row window is a valid zero and a two-row window is one absolute step.</summary>
    [Fact]
    public void WidthOneAndTwoGiveZeroAndTheAbsoluteStep()
    {
        var series = MathBlockValue.Vector([1d, 4d, 2d, 2d, -3d]);
        var one = Form(Source).Evaluate(Inputs(series, 1)).AsVector().ToArray();
        Assert.All(one, value => Assert.Equal(0L, BitConverter.DoubleToInt64Bits(value)));
        var two = Form(Source).Evaluate(Inputs(series, 2)).AsVector().ToArray();
        Assert.Equal([Sentinel, 3d, 2d, 0d, 5d], two);
        AssertSame(Inputs(series, 1));
        AssertSame(Inputs(series, 2));
    }

    /// <summary>Verifies a width above the series length is the same invalid result as the direct lift.</summary>
    [Fact]
    public void LengthBelowTheWindowIsInvalidLikeTheDirectLift()
    {
        var inputs = Inputs(MathBlockValue.Vector([1d, 2d, 3d]), 4);
        var result = Form(Source).Evaluate(inputs);
        Assert.False(result.IsValid);
        AssertSame(inputs);
    }

    /// <summary>Verifies an invalid series is the same invalid result as the direct lift, and so is an overflowing window.</summary>
    [Fact]
    public void InvalidInputAndNonfiniteWindowsMatchTheDirectLift()
    {
        var invalid = MathBlockValue.Invalid(MathBlockType.Vector(default, 5), "The series is not available.");
        AssertSame(Inputs(invalid, 2));

        var series = MathBlockValue.Vector([0d, 1.7e308d, -1.7e308d, 0d, 1d, 2d]);
        var form = Form(Source).Evaluate(Inputs(series, 3));
        var validity = Validity(Source).Evaluate([series, MathBlockValue.Scalar(3d)]).AsBooleanVector().ToArray();
        Assert.Equal([false, false, false, false, true, true], validity);
        Assert.Equal(Sentinel, form.AsVector()[2]);
        AssertSame(Inputs(series, 3));
    }
}
