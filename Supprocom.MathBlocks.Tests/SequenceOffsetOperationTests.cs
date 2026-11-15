namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the contract of the offset operations: first-true-offset, sum-over-offsets and maximum-over-offsets, each with its -valid sibling.</summary>
public sealed class SequenceOffsetOperationTests
{
    private const double Fill = -9d;
    private const double NoMatch = 77d;
    private static readonly double[] Counts8 = [0d, 1d, 2d, 3d, 4d, 5d, 6d, 7d];

    private static bool[] AllValid(int count) => [.. Enumerable.Repeat(true, count)];

    private static MathBlockOperation Operation(string identifier) => MathBlockCatalog.Standard.Get(identifier);

    // Runs the value operation and its sibling on the same inputs and checks that the sibling's row validity is the value
    // operation's: a row holds the fill exactly when it is not valid.
    private static (MathBlockValue Values, MathBlockValue Validity) Run(
        string identifier,
        double[] series,
        bool[] seriesValid,
        double[] counts,
        double start,
        double end)
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
                    Assert.Equal(BitConverter.DoubleToInt64Bits(Fill), BitConverter.DoubleToInt64Bits(rows[row]));
            }
        }
        return (values, validity);
    }

    private static void AssertRows(
        (MathBlockValue Values, MathBlockValue Validity) result,
        double[] expectedValues,
        bool[] expectedValid)
    {
        Assert.True(result.Values.IsValid, result.Values.InvalidReason);
        Assert.Equal(expectedValid, result.Validity.AsBooleanVector().ToArray());
        var actual = result.Values.AsVector().ToArray();
        Assert.Equal(expectedValues.Length, actual.Length);
        for (var row = 0; row < actual.Length; row++)
        {
            Assert.True(
                BitConverter.DoubleToInt64Bits(expectedValues[row]) == BitConverter.DoubleToInt64Bits(actual[row]),
                $"row {row}: expected {expectedValues[row]}, actual {actual[row]}");
        }
    }

    private static void AssertFlags(MathBlockValue validity, params bool[] expected) =>
        Assert.True(expected.AsSpan().SequenceEqual(validity.AsBooleanVector().ToArray()));

    private static double[] Zeros(int count, params (int Index, double Value)[] marks)
    {
        var values = new double[count];
        foreach (var (index, value) in marks)
            values[index] = value;
        return values;
    }

    /// <summary>Checks that the first, a middle and the last offset of the range are found, and that no match gives noMatch.</summary>
    [Fact]
    public void FirstTrueOffsetFindsTheFirstMiddleAndLastOffsetAndNoMatch()
    {
        var predicate = Zeros(8, (3, 1d));
        var result = Run("sequence.first-true-offset", predicate, AllValid(8), Counts8, 0d, 2d);
        AssertRows(
            result,
            [NoMatch, 2d, 1d, 0d, NoMatch, NoMatch, Fill, Fill],
            [true, true, true, true, true, true, false, false]);
    }

    /// <summary>Checks that an unavailable predicate row invalidates the row before a true, and is ignored after it.</summary>
    [Fact]
    public void FirstTrueOffsetReadsNoRowAfterTheFirstTrue()
    {
        var predicate = Zeros(8, (1, 1d), (4, 1d));
        var predicateValid = AllValid(8);
        predicateValid[2] = false;
        predicateValid[4] = false;
        var result = Run("sequence.first-true-offset", predicate, predicateValid, Counts8, 0d, 2d);
        // Row 0 matches at offset 1 and never reads the unavailable row 2. Row 1 matches at offset 0. Row 2 is unavailable
        // itself. Row 3 reads row 4 (unavailable) before it can reach anything else. Row 4 is unavailable. Row 5 finds no match.
        AssertRows(
            result,
            [1d, 0d, Fill, Fill, Fill, NoMatch, Fill, Fill],
            [true, true, false, false, false, true, false, false]);
    }

    /// <summary>Checks that rows beyond the series or beyond a gap in the counts are unreachable, unless a match comes first.</summary>
    [Fact]
    public void FirstTrueOffsetUnreachableOffsetsInvalidateTheRowUnlessAMatchComesFirst()
    {
        double[] counts = [0d, 1d, 0d, 1d, 2d, 3d];
        var predicate = Zeros(6, (1, 1d));
        var result = Run("sequence.first-true-offset", predicate, AllValid(6), counts, 0d, 2d);
        // Row 0 matches at offset 1 before the gap at row 2. Row 1 matches at 0. Row 2 and 3 have no match: row 2 reaches
        // row 3 (counts 1) and row 4 (counts 2); row 3 reaches rows 4 and 5.
        AssertRows(
            result,
            [1d, 0d, NoMatch, NoMatch, Fill, Fill],
            [true, true, true, true, false, false]);
        var noMatch = Run("sequence.first-true-offset", Zeros(6), AllValid(6), counts, 0d, 2d);
        AssertRows(noMatch, [Fill, Fill, NoMatch, NoMatch, Fill, Fill], [false, false, true, true, false, false]);
    }

    /// <summary>Checks negative and positive start and end, and that a negative zero is false.</summary>
    [Fact]
    public void FirstTrueOffsetHandlesNegativeAndPositiveOffsets()
    {
        double[] counts = [0d, 1d, 0d, 1d, 2d, 3d];
        var predicate = Zeros(6, (0, 1d), (3, 1d));
        var backward = Run("sequence.first-true-offset", predicate, AllValid(6), counts, -1d, 0d);
        // Offset -1 needs counts[t] >= 1: rows 0 and 2 start a series.
        AssertRows(backward, [Fill, -1d, Fill, 0d, -1d, NoMatch], [false, true, false, true, true, true]);
        var forward = Run("sequence.first-true-offset", Counts8.Select(_ => 1d).ToArray(), AllValid(8), Counts8, 1d, 2d);
        AssertRows(forward, [1d, 1d, 1d, 1d, 1d, 1d, 1d, Fill], [true, true, true, true, true, true, true, false]);
        var negativeZero = Run("sequence.first-true-offset", Zeros(8, (2, -0d)), AllValid(8), Counts8, 0d, 0d);
        AssertRows(negativeZero, [.. Enumerable.Repeat(NoMatch, 8)], AllValid(8));
        var wide = Run("sequence.first-true-offset", Zeros(8, (4, 1d)), AllValid(8), Counts8, -2d, 2d);
        AssertRows(wide, [Fill, Fill, 2d, 1d, 0d, -1d, -2d, Fill], [false, false, true, true, true, true, true, false]);
    }

    /// <summary>Checks that start above end, a non-integer offset and bad counts make the whole call invalid.</summary>
    [Theory]
    [InlineData("sequence.first-true-offset")]
    [InlineData("sequence.sum-over-offsets")]
    [InlineData("sequence.maximum-over-offsets")]
    public void WholeCallIsInvalidForBadOffsetsOrCounts(string identifier)
    {
        var series = Zeros(8, (3, 1d));
        Assert.False(Run(identifier, series, AllValid(8), Counts8, 2d, 1d).Values.IsValid);
        Assert.False(Run(identifier, series, AllValid(8), Counts8, 0.5d, 1d).Values.IsValid);
        Assert.False(Run(identifier, series, AllValid(8), Counts8, 0d, 1.5d).Values.IsValid);
        Assert.False(Run(identifier, series, AllValid(8), [0d, 1d, 2d, 3d, 4d, 5d, 6d, -1d], 0d, 1d).Values.IsValid);
        Assert.False(Run(identifier, series, AllValid(8), [0d, 1d, 2d, 3d, 4d, 5d, 6d, 0.5d], 0d, 1d).Values.IsValid);
        Assert.True(Run(identifier, series, AllValid(8), Counts8, 1d, 1d).Values.IsValid);
    }

    /// <summary>Checks the sum over a span, its running left-to-right order, and the negative zero and overflow rules.</summary>
    [Fact]
    public void SumOverOffsetsAddsLeftToRightFromPositiveZeroAndInvalidatesOverflow()
    {
        double[] series = [1d, 2d, 3d, 4d, 5d, 6d, 7d, 8d];
        AssertRows(
            Run("sequence.sum-over-offsets", series, AllValid(8), Counts8, 0d, 1d),
            [3d, 5d, 7d, 9d, 11d, 13d, 15d, Fill],
            [true, true, true, true, true, true, true, false]);
        AssertRows(
            Run("sequence.sum-over-offsets", series, AllValid(8), Counts8, -1d, 1d),
            [Fill, 6d, 9d, 12d, 15d, 18d, 21d, Fill],
            [false, true, true, true, true, true, true, false]);
        AssertRows(
            Run("sequence.sum-over-offsets", series, AllValid(8), Counts8, 1d, 2d),
            [5d, 7d, 9d, 11d, 13d, 15d, Fill, Fill],
            [true, true, true, true, true, true, false, false]);
        AssertRows(
            Run("sequence.sum-over-offsets", series, AllValid(8), Counts8, -2d, -1d),
            [Fill, Fill, 3d, 5d, 7d, 9d, 11d, 13d],
            [false, false, true, true, true, true, true, true]);
        // 0.0 + -0.0 is +0.0, as in PatternResearcher's sum.
        var negativeZeros = Run("sequence.sum-over-offsets", [.. Enumerable.Repeat(-0d, 8)], AllValid(8), Counts8, 0d, 1d);
        Assert.Equal(0L, BitConverter.DoubleToInt64Bits(negativeZeros.Values.AsVector()[0]));
        double[] large = [1.7e308d, 1.7e308d, 1d, 1d, 1d, 1d, 1d, 1d];
        AssertRows(
            Run("sequence.sum-over-offsets", large, AllValid(8), Counts8, 0d, 1d),
            [Fill, 1.7e308d + 1d, 2d, 2d, 2d, 2d, 2d, Fill],
            [false, true, true, true, true, true, true, false]);
    }

    /// <summary>Checks that a gap in the counts inside the span, and an unavailable row of the span, invalidate the row.</summary>
    [Theory]
    [InlineData("sequence.sum-over-offsets")]
    [InlineData("sequence.maximum-over-offsets")]
    public void RangeOperationsInvalidateRowsWithAGapOrAnUnavailableRowInTheSpan(string identifier)
    {
        double[] series = [4d, 3d, 2d, 1d, 5d, 6d];
        double[] counts = [0d, 1d, 0d, 1d, 2d, 3d];
        var gap = Run(identifier, series, AllValid(6), counts, 0d, 1d);
        AssertFlags(gap.Validity, true, false, true, true, true, false);
        var gapBefore = Run(identifier, series, AllValid(6), counts, -1d, 0d);
        AssertFlags(gapBefore.Validity, false, true, false, true, true, true);
        var seriesValid = AllValid(6);
        seriesValid[4] = false;
        var unavailable = Run(identifier, series, seriesValid, [0d, 1d, 2d, 3d, 4d, 5d], 0d, 1d);
        AssertFlags(unavailable.Validity, true, true, true, false, false, false);
    }

    /// <summary>Checks the maximum over a span, including all negative zeros and a mix of zeros.</summary>
    [Fact]
    public void MaximumOverOffsetsUsesScalarMaximumsRuleForZeros()
    {
        double[] series = [1d, 5d, 2d, 4d, 3d, -6d, 0d, 8d];
        AssertRows(
            Run("sequence.maximum-over-offsets", series, AllValid(8), Counts8, -1d, 1d),
            [Fill, 5d, 5d, 4d, 4d, 3d, 8d, Fill],
            [false, true, true, true, true, true, true, false]);
        AssertRows(
            Run("sequence.maximum-over-offsets", series, AllValid(8), Counts8, 0d, 2d),
            [5d, 5d, 4d, 4d, 3d, 8d, Fill, Fill],
            [true, true, true, true, true, true, false, false]);
        var allNegativeZero = Run("sequence.maximum-over-offsets", [.. Enumerable.Repeat(-0d, 8)], AllValid(8), Counts8, 0d, 1d);
        for (var row = 0; row < 7; row++)
            Assert.Equal(BitConverter.DoubleToInt64Bits(-0d), BitConverter.DoubleToInt64Bits(allNegativeZero.Values.AsVector()[row]));
        double[] zeros = [-0d, 0d, -0d, 0d, -0d, -0d, 0d, -0d];
        var mixed = Run("sequence.maximum-over-offsets", zeros, AllValid(8), Counts8, 0d, 1d);
        for (var row = 0; row < 7; row++)
        {
            Assert.Equal(
                BitConverter.DoubleToInt64Bits(Math.Max(zeros[row], zeros[row + 1])),
                BitConverter.DoubleToInt64Bits(mixed.Values.AsVector()[row]));
        }
        Assert.Equal(0L, BitConverter.DoubleToInt64Bits(mixed.Values.AsVector()[0]));
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
