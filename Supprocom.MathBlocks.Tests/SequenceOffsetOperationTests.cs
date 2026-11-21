namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the contract of the offset operations: first-true-offset, sum-over-offsets and maximum-over-offsets, each with its -valid sibling.</summary>
public sealed class SequenceOffsetOperationTests
{
    private const float Fill = -9f;
    private const float NoMatch = 77f;
    private static readonly float[] Counts8 = [0f, 1f, 2f, 3f, 4f, 5f, 6f, 7f];

    private static bool[] AllValid(int count) => [.. Enumerable.Repeat(true, count)];

    private static MathBlockOperation Operation(string identifier) => MathBlockCatalog.Standard.Get(identifier);

    // Runs the value operation and its sibling on the same inputs and checks that the sibling's row validity is the value
    // operation's: a row holds the fill exactly when it is not valid.
    private static (MathBlockValue Values, MathBlockValue Validity) Run(
        string identifier,
        float[] series,
        bool[] seriesValid,
        float[] counts,
        float start,
        float end)
    {
        var firstTrue = string.Equals(identifier, "sequence.first-true-offset", StringComparison.Ordinal);
        MathBlockValue[] common =
        [
            MathBlockValue.Vector(series), MathBlockValue.BooleanVector(seriesValid), MathBlockValue.Vector(counts),
            MathBlockValue.Scalar(start), MathBlockValue.Scalar(end)
        ];
        MathBlockValue[] valueInputs = firstTrue
            ? [.. common, MathBlockValue.Scalar(NoMatch), MathBlockValue.Scalar(Fill)]
            : [.. common, MathBlockValue.Scalar(Fill)];
        var values = Operation(identifier).Evaluate(valueInputs);
        var validity = Operation(identifier + "-valid").Evaluate(common);
        Assert.Equal(values.IsValid, validity.IsValid);
        if (values.IsValid)
        {
            var flags = validity.AsBooleanVector();
            var rows = values.AsVector();
            Assert.Equal(rows.Count, flags.Count);
            for (var row = 0; row < rows.Count; row++)
            {
                if (!flags[row])
                    Assert.Equal(BitConverter.SingleToInt32Bits(Fill), BitConverter.SingleToInt32Bits(rows[row]));
            }
        }
        return (values, validity);
    }

    private static void AssertRows(
        (MathBlockValue Values, MathBlockValue Validity) result,
        float[] expectedValues,
        bool[] expectedValid)
    {
        Assert.True(result.Values.IsValid, result.Values.InvalidReason);
        Assert.Equal(expectedValid, result.Validity.AsBooleanVector().ToArray());
        var actual = result.Values.AsVector().ToArray();
        Assert.Equal(expectedValues.Length, actual.Length);
        for (var row = 0; row < actual.Length; row++)
        {
            Assert.True(
                BitConverter.SingleToInt32Bits(expectedValues[row]) == BitConverter.SingleToInt32Bits(actual[row]),
                $"row {row}: expected {expectedValues[row]}, actual {actual[row]}");
        }
    }

    private static void AssertFlags(MathBlockValue validity, params bool[] expected) =>
        Assert.True(expected.AsSpan().SequenceEqual(validity.AsBooleanVector().ToArray()));

    private static float[] Zeros(int count, params (int Index, float Value)[] marks)
    {
        var values = new float[count];
        foreach (var (index, value) in marks)
            values[index] = value;
        return values;
    }

    /// <summary>Checks that the first, a middle and the last offset of the range are found, and that no match gives noMatch.</summary>
    [Fact]
    public void FirstTrueOffsetFindsTheFirstMiddleAndLastOffsetAndNoMatch()
    {
        var predicate = Zeros(8, (3, 1f));
        var result = Run("sequence.first-true-offset", predicate, AllValid(8), Counts8, 0f, 2f);
        AssertRows(
            result,
            [NoMatch, 2f, 1f, 0f, NoMatch, NoMatch, Fill, Fill],
            [true, true, true, true, true, true, false, false]);
    }

    /// <summary>Checks that an unavailable predicate row invalidates the row before a true, and is ignored after it.</summary>
    [Fact]
    public void FirstTrueOffsetReadsNoRowAfterTheFirstTrue()
    {
        var predicate = Zeros(8, (1, 1f), (4, 1f));
        var predicateValid = AllValid(8);
        predicateValid[2] = false;
        predicateValid[4] = false;
        var result = Run("sequence.first-true-offset", predicate, predicateValid, Counts8, 0f, 2f);
        // Row 0 matches at offset 1 and never reads the unavailable row 2. Row 1 matches at offset 0. Row 2 is unavailable
        // itself. Row 3 reads row 4 (unavailable) before it can reach anything else. Row 4 is unavailable. Row 5 finds no match.
        AssertRows(
            result,
            [1f, 0f, Fill, Fill, Fill, NoMatch, Fill, Fill],
            [true, true, false, false, false, true, false, false]);
    }

    /// <summary>Checks that rows beyond the series or beyond a gap in the counts are unreachable, unless a match comes first.</summary>
    [Fact]
    public void FirstTrueOffsetUnreachableOffsetsInvalidateTheRowUnlessAMatchComesFirst()
    {
        float[] counts = [0f, 1f, 0f, 1f, 2f, 3f];
        var predicate = Zeros(6, (1, 1f));
        var result = Run("sequence.first-true-offset", predicate, AllValid(6), counts, 0f, 2f);
        // Row 0 matches at offset 1 before the gap at row 2. Row 1 matches at 0. Row 2 and 3 have no match: row 2 reaches
        // row 3 (counts 1) and row 4 (counts 2); row 3 reaches rows 4 and 5.
        AssertRows(
            result,
            [1f, 0f, NoMatch, NoMatch, Fill, Fill],
            [true, true, true, true, false, false]);
        var noMatch = Run("sequence.first-true-offset", Zeros(6), AllValid(6), counts, 0f, 2f);
        AssertRows(noMatch, [Fill, Fill, NoMatch, NoMatch, Fill, Fill], [false, false, true, true, false, false]);
    }

    /// <summary>Checks negative and positive start and end, and that a negative zero is false.</summary>
    [Fact]
    public void FirstTrueOffsetHandlesNegativeAndPositiveOffsets()
    {
        float[] counts = [0f, 1f, 0f, 1f, 2f, 3f];
        var predicate = Zeros(6, (0, 1f), (3, 1f));
        var backward = Run("sequence.first-true-offset", predicate, AllValid(6), counts, -1f, 0f);
        // Offset -1 needs counts[t] >= 1: rows 0 and 2 start a series.
        AssertRows(backward, [Fill, -1f, Fill, 0f, -1f, NoMatch], [false, true, false, true, true, true]);
        var forward = Run("sequence.first-true-offset", Counts8.Select(_ => 1f).ToArray(), AllValid(8), Counts8, 1f, 2f);
        AssertRows(forward, [1f, 1f, 1f, 1f, 1f, 1f, 1f, Fill], [true, true, true, true, true, true, true, false]);
        var negativeZero = Run("sequence.first-true-offset", Zeros(8, (2, -0f)), AllValid(8), Counts8, 0f, 0f);
        AssertRows(negativeZero, [.. Enumerable.Repeat(NoMatch, 8)], AllValid(8));
        var wide = Run("sequence.first-true-offset", Zeros(8, (4, 1f)), AllValid(8), Counts8, -2f, 2f);
        AssertRows(wide, [Fill, Fill, 2f, 1f, 0f, -1f, -2f, Fill], [false, false, true, true, true, true, true, false]);
    }

    /// <summary>Checks that start above end, a non-integer offset and bad counts make the whole call invalid.</summary>
    [Theory]
    [InlineData("sequence.first-true-offset")]
    [InlineData("sequence.sum-over-offsets")]
    [InlineData("sequence.maximum-over-offsets")]
    public void WholeCallIsInvalidForBadOffsetsOrCounts(string identifier)
    {
        var series = Zeros(8, (3, 1f));
        Assert.False(Run(identifier, series, AllValid(8), Counts8, 2f, 1f).Values.IsValid);
        Assert.False(Run(identifier, series, AllValid(8), Counts8, 0.5f, 1f).Values.IsValid);
        Assert.False(Run(identifier, series, AllValid(8), Counts8, 0f, 1.5f).Values.IsValid);
        Assert.False(Run(identifier, series, AllValid(8), [0f, 1f, 2f, 3f, 4f, 5f, 6f, -1f], 0f, 1f).Values.IsValid);
        Assert.False(Run(identifier, series, AllValid(8), [0f, 1f, 2f, 3f, 4f, 5f, 6f, 0.5f], 0f, 1f).Values.IsValid);
        Assert.True(Run(identifier, series, AllValid(8), Counts8, 1f, 1f).Values.IsValid);
    }

    /// <summary>Checks the sum over a span, its running left-to-right order, and the negative zero and overflow rules.</summary>
    [Fact]
    public void SumOverOffsetsAddsLeftToRightFromPositiveZeroAndInvalidatesOverflow()
    {
        float[] series = [1f, 2f, 3f, 4f, 5f, 6f, 7f, 8f];
        AssertRows(
            Run("sequence.sum-over-offsets", series, AllValid(8), Counts8, 0f, 1f),
            [3f, 5f, 7f, 9f, 11f, 13f, 15f, Fill],
            [true, true, true, true, true, true, true, false]);
        AssertRows(
            Run("sequence.sum-over-offsets", series, AllValid(8), Counts8, -1f, 1f),
            [Fill, 6f, 9f, 12f, 15f, 18f, 21f, Fill],
            [false, true, true, true, true, true, true, false]);
        AssertRows(
            Run("sequence.sum-over-offsets", series, AllValid(8), Counts8, 1f, 2f),
            [5f, 7f, 9f, 11f, 13f, 15f, Fill, Fill],
            [true, true, true, true, true, true, false, false]);
        AssertRows(
            Run("sequence.sum-over-offsets", series, AllValid(8), Counts8, -2f, -1f),
            [Fill, Fill, 3f, 5f, 7f, 9f, 11f, 13f],
            [false, false, true, true, true, true, true, true]);
        // 0.0 + -0.0 is +0.0, as in PatternResearcher's sum.
        var negativeZeros = Run("sequence.sum-over-offsets", [.. Enumerable.Repeat(-0f, 8)], AllValid(8), Counts8, 0f, 1f);
        Assert.Equal(0L, BitConverter.SingleToInt32Bits(negativeZeros.Values.AsVector()[0]));
        float[] large = [3.38e38f, 3.38e38f, 1f, 1f, 1f, 1f, 1f, 1f];
        AssertRows(
            Run("sequence.sum-over-offsets", large, AllValid(8), Counts8, 0f, 1f),
            [Fill, 3.38e38f + 1f, 2f, 2f, 2f, 2f, 2f, Fill],
            [false, true, true, true, true, true, true, false]);
    }

    /// <summary>Checks that a gap in the counts inside the span, and an unavailable row of the span, invalidate the row.</summary>
    [Theory]
    [InlineData("sequence.sum-over-offsets")]
    [InlineData("sequence.maximum-over-offsets")]
    public void RangeOperationsInvalidateRowsWithAGapOrAnUnavailableRowInTheSpan(string identifier)
    {
        float[] series = [4f, 3f, 2f, 1f, 5f, 6f];
        float[] counts = [0f, 1f, 0f, 1f, 2f, 3f];
        var gap = Run(identifier, series, AllValid(6), counts, 0f, 1f);
        AssertFlags(gap.Validity, true, false, true, true, true, false);
        var gapBefore = Run(identifier, series, AllValid(6), counts, -1f, 0f);
        AssertFlags(gapBefore.Validity, false, true, false, true, true, true);
        var seriesValid = AllValid(6);
        seriesValid[4] = false;
        var unavailable = Run(identifier, series, seriesValid, [0f, 1f, 2f, 3f, 4f, 5f], 0f, 1f);
        AssertFlags(unavailable.Validity, true, true, true, false, false, false);
    }

    /// <summary>Checks the maximum over a span, including all negative zeros and a mix of zeros.</summary>
    [Fact]
    public void MaximumOverOffsetsUsesScalarMaximumsRuleForZeros()
    {
        float[] series = [1f, 5f, 2f, 4f, 3f, -6f, 0f, 8f];
        AssertRows(
            Run("sequence.maximum-over-offsets", series, AllValid(8), Counts8, -1f, 1f),
            [Fill, 5f, 5f, 4f, 4f, 3f, 8f, Fill],
            [false, true, true, true, true, true, true, false]);
        AssertRows(
            Run("sequence.maximum-over-offsets", series, AllValid(8), Counts8, 0f, 2f),
            [5f, 5f, 4f, 4f, 3f, 8f, Fill, Fill],
            [true, true, true, true, true, true, false, false]);
        var allNegativeZero = Run("sequence.maximum-over-offsets", [.. Enumerable.Repeat(-0f, 8)], AllValid(8), Counts8, 0f, 1f);
        for (var row = 0; row < 7; row++)
            Assert.Equal(BitConverter.SingleToInt32Bits(-0f), BitConverter.SingleToInt32Bits(allNegativeZero.Values.AsVector()[row]));
        float[] zeros = [-0f, 0f, -0f, 0f, -0f, -0f, 0f, -0f];
        var mixed = Run("sequence.maximum-over-offsets", zeros, AllValid(8), Counts8, 0f, 1f);
        for (var row = 0; row < 7; row++)
        {
            Assert.Equal(
                BitConverter.SingleToInt32Bits(Math.Max(zeros[row], zeros[row + 1])),
                BitConverter.SingleToInt32Bits(mixed.Values.AsVector()[row]));
        }
        Assert.Equal(0L, BitConverter.SingleToInt32Bits(mixed.Values.AsVector()[0]));
    }

    /// <summary>Checks that every offset operation and sibling is labelled Forward and returns a vector of the series length.</summary>
    [Theory]
    [InlineData("sequence.first-true-offset@1")]
    [InlineData("sequence.first-true-offset-valid@1")]
    [InlineData("sequence.sum-over-offsets@1")]
    [InlineData("sequence.sum-over-offsets-valid@1")]
    [InlineData("sequence.maximum-over-offsets@1")]
    [InlineData("sequence.maximum-over-offsets-valid@1")]
    public void CausalityIsForwardAndTheOutputKeepsTheSeriesLength(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var separator = identity.IndexOf('@', StringComparison.Ordinal);
        var operation = MathBlockCatalog.Standard.Get(identity[..separator], 1);
        Assert.Equal(MathBlockCausality.Forward, operation.Causality.Kind);
        var types = operation.PerformanceCase.Inputs.Select(input => input.Type).ToArray();
        var output = operation.ResolveOutputType(types);
        var expectedKind = identity.Contains("-valid", StringComparison.Ordinal)
            ? MathBlockValueKind.BooleanVector
            : MathBlockValueKind.Vector;
        Assert.Equal(expectedKind, output.Kind);
        Assert.Equal(types[0].Rows, output.Rows);
    }

    /// <summary>Checks that an operation rejects series of different lengths at type resolution.</summary>
    [Fact]
    public void MismatchedRowCountsAreRejected()
    {
        var operation = Operation("sequence.sum-over-offsets");
        var types = operation.PerformanceCase.Inputs.Select(input => input.Type).ToArray();
        types[2] = MathBlockType.Vector(default, types[0].Rows + 1);
        Assert.Throws<InvalidOperationException>(() => operation.ResolveOutputType(types));
    }
}
