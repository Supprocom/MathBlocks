namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies <c>sequence.prefix-difference-over-offsets@1</c> and its validity sibling against the contract of the design.</summary>
public sealed class MathBlockPrefixDifferenceTests
{
    private static (float[] Values, bool[] Valid) Run(MathBlockValue[] formInputs)
    {
        var form = PrefixDifferenceCases.Operation(PrefixDifferenceCases.Form).Evaluate(formInputs);
        var validity = PrefixDifferenceCases.Operation(PrefixDifferenceCases.Validity).Evaluate(PrefixDifferenceCases.ValidityInputs(formInputs));
        Assert.True(form.IsValid, form.InvalidReason);
        Assert.True(validity.IsValid, validity.InvalidReason);
        var values = form.AsVector().ToArray();
        var valid = validity.AsBooleanVector().ToArray();
        // The sibling marks exactly the rows the form computed: every other row holds the fill.
        for (var row = 0; row < values.Length; row++)
            if (!valid[row])
                Assert.Equal(PrefixDifferenceCases.Fill, values[row]);
        return (values, valid);
    }

    private static void AssertRows(MathBlockValue[] inputs, float?[] expected)
    {
        var (values, valid) = Run(inputs);
        Assert.Equal(expected.Length, values.Length);
        for (var row = 0; row < expected.Length; row++)
        {
            Assert.Equal(expected[row].HasValue, valid[row]);
            Assert.Equal(expected[row] ?? PrefixDifferenceCases.Fill, values[row]);
        }
    }

    /// <summary>Verifies an unavailable row inside the window makes the row invalid, and a window that avoids it stays valid.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void AnUnavailableRowInsideTheWindowInvalidatesTheRow() => AssertRows(
        PrefixDifferenceCases.FormInputs(PrefixDifferenceCases.Sequence(5), [true, true, false, true, true], PrefixDifferenceCases.Sequence(5, 0f), -1f, 0f),
        [null, 3f, null, null, 9f]);

    /// <summary>Verifies an unavailable row before the window is ignored by every later window.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void AnUnavailableRowBeforeTheWindowIsIgnored() => AssertRows(
        PrefixDifferenceCases.FormInputs(PrefixDifferenceCases.Sequence(5), [false, true, true, true, true], PrefixDifferenceCases.Sequence(5, 0f), 0f, 1f),
        [null, 5f, 7f, 9f, null]);

    /// <summary>Verifies the prefix restarts at every row whose count is 0, and a window never crosses a segment.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void SegmentsStartAtZeroCountsAndWindowsStayInsideOne()
    {
        float[] values = [1f, 2f, 3f, 10f, 20f, 30f];
        float[] counts = [0f, 1f, 2f, 0f, 1f, 2f];
        AssertRows(PrefixDifferenceCases.FormInputs(values, PrefixDifferenceCases.All(6), counts, 0f, 1f), [3f, 5f, null, 30f, 50f, null]);
        AssertRows(PrefixDifferenceCases.FormInputs(values, PrefixDifferenceCases.All(6), counts, -1f, 0f), [null, 3f, 5f, null, 30f, 50f]);
        // Row 0 starts a segment whatever its count is.
        AssertRows(
            PrefixDifferenceCases.FormInputs(PrefixDifferenceCases.Sequence(4), PrefixDifferenceCases.All(4), [3f, 4f, 0f, 1f], 0f, 1f),
            [3f, null, 7f, null]);
    }

    /// <summary>Verifies a window that reaches both before and after the row, and the rows near the start and the tail.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void WindowsBeforeAndAfterTheRowAndTheTailAreValidOnlyInsideTheSeries()
    {
        AssertRows(
            PrefixDifferenceCases.FormInputs(PrefixDifferenceCases.Sequence(7), PrefixDifferenceCases.All(7), PrefixDifferenceCases.Sequence(7, 0f), -2f, 1f),
            [null, null, 10f, 14f, 18f, 22f, null]);
        AssertRows(
            PrefixDifferenceCases.FormInputs(PrefixDifferenceCases.Sequence(5), PrefixDifferenceCases.All(5), PrefixDifferenceCases.Sequence(5, 0f), 1f, 2f),
            [5f, 7f, 9f, null, null]);
        AssertRows(
            PrefixDifferenceCases.FormInputs(PrefixDifferenceCases.Sequence(4), PrefixDifferenceCases.All(4), PrefixDifferenceCases.Sequence(4, 0f), 100f, 200f),
            [null, null, null, null]);
    }

    /// <summary>Verifies a prefix that overflows keeps the earlier rows, where vector.cumulative-sum invalidates the whole result, and an overflowing difference invalidates its row.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void AnOverflowingPrefixKeepsTheEarlierRows()
    {
        float[] values = [3.33e38f, 3.33e38f, 1f, 2f, 3f];
        AssertRows(
            PrefixDifferenceCases.FormInputs(values, PrefixDifferenceCases.All(5), PrefixDifferenceCases.Sequence(5, 0f), 0f, 0f),
            [3.33e38f, null, null, null, null]);
        Assert.False(PrefixDifferenceCases.Operation("vector.cumulative-sum@1").Evaluate(MathBlockValue.Vector(values)).IsValid);
        AssertRows(
            PrefixDifferenceCases.FormInputs([-3.38e38f, 3.38e38f, 3.38e38f], PrefixDifferenceCases.All(3), PrefixDifferenceCases.Sequence(3, 0f), 1f, 2f),
            [null, null, null]);
    }

    /// <summary>Verifies the prefix arithmetic keeps its own bits: the single-row difference of the running sum, not the row.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void ThePrefixDifferenceKeepsTheBitsOfTheRunningSum() => AssertRows(
        PrefixDifferenceCases.FormInputs([1e16f, 1f, 1f, 1f], PrefixDifferenceCases.All(4), PrefixDifferenceCases.Sequence(4, 0f), 0f, 0f),
        [1e16f, 0f, 0f, 0f]);

    /// <summary>Verifies every call that is invalid as a whole gives an invalid value of the declared type in both operations.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void WholeCallInvalidInputsInvalidateBothOperations()
    {
        foreach (var (name, inputs) in PrefixDifferenceCases.WholeCallInvalid())
        {
            var form = PrefixDifferenceCases.Operation(PrefixDifferenceCases.Form).Evaluate(inputs);
            var validity = PrefixDifferenceCases.Operation(PrefixDifferenceCases.Validity).Evaluate(PrefixDifferenceCases.ValidityInputs(inputs));
            Assert.False(form.IsValid, name);
            Assert.False(validity.IsValid, name);
            Assert.Equal(MathBlockValueKind.Vector, form.Type.Kind);
            Assert.Equal(MathBlockValueKind.BooleanVector, validity.Type.Kind);
        }
    }

    /// <summary>Verifies series of different lengths are rejected by the type rule, and an empty series beside a longer one gives an invalid value.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void SeriesOfDifferentLengthsAreRejectedOrInvalid()
    {
        foreach (var (name, inputs) in PrefixDifferenceCases.LengthMismatch())
        {
            Assert.Throws<InvalidOperationException>(() => PrefixDifferenceCases.Operation(PrefixDifferenceCases.Form).Evaluate(inputs));
            Assert.Throws<InvalidOperationException>(() => PrefixDifferenceCases.Operation(PrefixDifferenceCases.Validity).Evaluate(PrefixDifferenceCases.ValidityInputs(inputs)));
            Assert.NotEmpty(name);
        }

        foreach (var (name, inputs) in PrefixDifferenceCases.EmptyBesideLonger())
        {
            Assert.False(PrefixDifferenceCases.Operation(PrefixDifferenceCases.Form).Evaluate(inputs).IsValid, name);
            Assert.False(PrefixDifferenceCases.Operation(PrefixDifferenceCases.Validity).Evaluate(PrefixDifferenceCases.ValidityInputs(inputs)).IsValid, name);
        }
    }

    /// <summary>Verifies every shared case is valid, empty series give empty results, and the sibling agrees with the form.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void EverySharedCaseIsAValidCall()
    {
        var count = 0;
        foreach (var (_, inputs) in PrefixDifferenceCases.Valid())
        {
            var (values, valid) = Run(inputs);
            Assert.Equal(inputs[0].AsVector().Count, values.Length);
            Assert.Equal(values.Length, valid.Length);
            count++;
        }

        Assert.Equal(16, count);
    }

    /// <summary>
    /// Verifies a clean window agrees with the left-to-right sum of its rows to within rounding, and is valid exactly where
    /// that sum exists. The last bits differ from sum-over-offsets by design, so only validity is compared exactly.
    /// </summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void ACleanWindowAgreesWithTheDirectSumToWithinRounding()
    {
        var values = PrefixDifferenceCases.Sequence(20, 0.1f);
        var counts = PrefixDifferenceCases.Sequence(20, 0f);
        var available = PrefixDifferenceCases.All(20);
        foreach (var (start, end) in new[] { (-3, 5), (0, 0), (-1, 1), (2, 4) })
        {
            var (result, valid) = Run(PrefixDifferenceCases.FormInputs(values, available, counts, start, end));
            var sumOverOffsets = MathBlockCatalog.Standard.Operations.FirstOrDefault(
                operation => string.Equals(operation.Identity, "sequence.sum-over-offsets@1", StringComparison.Ordinal));
            MathBlockValue? reference = sumOverOffsets?.Evaluate(
                MathBlockValue.Vector(values),
                MathBlockValue.BooleanVector(available),
                MathBlockValue.Vector(counts),
                MathBlockValue.Scalar(start),
                MathBlockValue.Scalar(end),
                MathBlockValue.Scalar(PrefixDifferenceCases.Fill));
            for (var row = 0; row < values.Length; row++)
            {
                var direct = PrefixDifferenceCases.DirectWindowSum(values, available, row, start, end);
                Assert.Equal(direct.HasValue, valid[row]);
                if (direct is { } expected)
                    Assert.True(Math.Abs(expected - result[row]) <= 2e-6f * Math.Max(1f, Math.Abs(expected)), $"row {row}: {result[row]:R} against {expected:R}");
            }

            // When sum-over-offsets is in the catalog, it reads the same rows: its values may differ in the last bits.
            if (reference is { IsValid: true } sums)
            {
                var sumValues = sums.AsVector();
                for (var row = 0; row < values.Length; row++)
                    if (valid[row])
                        Assert.True(Math.Abs(sumValues[row] - result[row]) <= 2e-6f * Math.Max(1f, Math.Abs(sumValues[row])));
            }
        }
    }

    /// <summary>Verifies both operations are labelled Forward and that the label holds against the causality property check.</summary>
    [Fact]
    [Trait("Category", "PrefixDifference")]
    public void BothOperationsAreForwardAndTheLabelHolds()
    {
        foreach (var identity in new[] { PrefixDifferenceCases.Form, PrefixDifferenceCases.Validity })
        {
            var operation = PrefixDifferenceCases.Operation(identity);
            Assert.Equal(MathBlockCausality.Forward, operation.Causality.Kind);
            Assert.Empty(MathBlockCausalityChecks.Check(operation));
        }
    }
}
