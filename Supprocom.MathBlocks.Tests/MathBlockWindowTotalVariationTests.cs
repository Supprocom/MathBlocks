using static Supprocom.MathBlocks.Tests.MathBlockWindowM2TestSupport;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the window.path.total-variation rows against the direct lift of the source, bit for bit.</summary>
public sealed class MathBlockWindowTotalVariationTests
{
    private const string Source = "path.total-variation";
    private const float Sentinel = 777.25f;

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
            var plain = Enumerable.Range(0, length).Select(_ => (random.NextSingle() - 0.5f) * 10f).ToArray();
            var zeros = Enumerable.Range(0, length).Select(row => row % 3 == 0 ? -0f : row % 3 == 1 ? 0f : 1.4e-45f).ToArray();
            // Alternating extremes: every window of two or more rows sums to infinity, a lone big step overflows later.
            var extremes = Enumerable.Range(0, length).Select(row => row % 2 == 0 ? 3.38e38f : -3.38e38f).ToArray();
            var mixed = Enumerable.Range(0, length).Select(row => row % 40 == 39 ? 3.38e38f * (row % 80 == 39 ? 1f : -1f) : 1f).ToArray();
            foreach (var series in new[] { plain, zeros, extremes, mixed })
                foreach (var width in Widths.Where(width => width <= length))
                    AssertSame(Inputs(MathBlockValue.Vector(series), width));
        }
    }

    /// <summary>Verifies widths 1 and 2: a one-row window is a valid zero and a two-row window is one absolute step.</summary>
    [Fact]
    public void WidthOneAndTwoGiveZeroAndTheAbsoluteStep()
    {
        var series = MathBlockValue.Vector([1f, 4f, 2f, 2f, -3f]);
        var one = Form(Source).Evaluate(Inputs(series, 1)).AsVector().ToArray();
        Assert.All(one, value => Assert.Equal(0L, BitConverter.SingleToInt32Bits(value)));
        var two = Form(Source).Evaluate(Inputs(series, 2)).AsVector().ToArray();
        Assert.Equal([Sentinel, 3f, 2f, 0f, 5f], two);
        AssertSame(Inputs(series, 1));
        AssertSame(Inputs(series, 2));
    }

    /// <summary>Verifies a width above the series length is the same invalid result as the direct lift.</summary>
    [Fact]
    public void LengthBelowTheWindowIsInvalidLikeTheDirectLift()
    {
        var inputs = Inputs(MathBlockValue.Vector([1f, 2f, 3f]), 4);
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

        var series = MathBlockValue.Vector([0f, 3.38e38f, -3.38e38f, 0f, 1f, 2f]);
        var form = Form(Source).Evaluate(Inputs(series, 3));
        var validity = Validity(Source).Evaluate([series, MathBlockValue.Scalar(3f)]).AsBooleanVector().ToArray();
        Assert.Equal([false, false, false, false, true, true], validity);
        Assert.Equal(Sentinel, form.AsVector()[2]);
        AssertSame(Inputs(series, 3));
    }
}
