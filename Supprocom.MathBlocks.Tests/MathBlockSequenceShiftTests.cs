namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the CoreCLR contract of <c>sequence.lead@1</c>, <c>sequence.lead-valid@1</c>, <c>sequence.lag@1</c> and <c>sequence.lag-valid@1</c>.</summary>
public sealed class MathBlockSequenceShiftTests
{
    private const double Fill = -99d;

    private static readonly double[] Series = [1d, 2d, 3d, 4d, 5d, 6d, 7d, 8d, 9d];

    // Rows 0-2 are one run, rows 3-4 a second one, rows 5-8 a third: rows 3 and 5 start a series or follow a gap.
    private static readonly double[] Counts = [0d, 1d, 2d, 0d, 1d, 0d, 1d, 2d, 3d];

    // Row 7 is unavailable.
    private static readonly bool[] Available = [true, true, true, true, true, true, true, false, true];

    /// <summary>Gets the identities the shift forms are registered under.</summary>
    public static TheoryData<string> Identities =>
        ["sequence.lead", "sequence.lead-valid", "sequence.lag", "sequence.lag-valid"];

    /// <summary>Verifies the causality labels: the leads are Forward and the lags are Expanding, as sequence.difference is.</summary>
    [Theory]
    [Trait("Category", "BlockContract")]
    [InlineData("sequence.lead", MathBlockCausality.Forward)]
    [InlineData("sequence.lead-valid", MathBlockCausality.Forward)]
    [InlineData("sequence.lag", MathBlockCausality.Expanding)]
    [InlineData("sequence.lag-valid", MathBlockCausality.Expanding)]
    public void CausalityLabelsAreForwardForTheLeadsAndExpandingForTheLags(string identifier, MathBlockCausality expected)
    {
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);

        Assert.Equal(expected, operation.Causality.Kind);
        Assert.Equal(expected, MathBlockCausalityIndex.Resolve(operation.Identity).Kind);
    }

    /// <summary>Verifies the arities, the type signatures and the output types.</summary>
    [Theory]
    [Trait("Category", "BlockContract")]
    [MemberData(nameof(Identities))]
    public void TypesFollowTheSeriesLength(string identifier)
    {
        ArgumentNullException.ThrowIfNull(identifier);
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var validity = identifier.EndsWith("-valid", StringComparison.Ordinal);
        Assert.Equal(validity ? 4 : 5, operation.Arity);
        Assert.NotNull(operation.TypeSignature);

        var types = new List<MathBlockType>
        {
            MathBlockType.Vector(MathBlockUnit.Basis1, 7),
            MathBlockType.BooleanVector(7),
            MathBlockType.Vector(MathBlockUnit.Dimensionless, 7),
            MathBlockType.Scalar(MathBlockUnit.Dimensionless)
        };
        if (!validity)
            types.Add(MathBlockType.Scalar(MathBlockUnit.Basis1));

        var output = operation.ResolveOutputType(types);

        Assert.Equal(validity ? MathBlockType.BooleanVector(7) : MathBlockType.Vector(MathBlockUnit.Basis1, 7), output);
        if (!validity)
        {
            types[4] = MathBlockType.Scalar(MathBlockUnit.Basis2);
            Assert.Throws<InvalidOperationException>(() => operation.ResolveOutputType(types));
        }
        types[3] = MathBlockType.Scalar(MathBlockUnit.Basis1);
        Assert.Throws<InvalidOperationException>(() => operation.ResolveOutputType(types));
    }

    /// <summary>Verifies the lead on chained rows, a gap, a series start, the tail and an unavailable row, for k = 1.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void LeadReadsTheNextRowOnlyWhenChainedAndAvailable()
    {
        // Row 0 -> 1, 1 -> 2 are chained; 2 -> 3 is a series start; 3 -> 4 chained; 4 -> 5 a gap; 5 -> 6 and 6 -> 7 chained but row 7 is
        // unavailable; 7 -> 8 chained; row 8 is the tail.
        var expected = new[] { 2d, 3d, Fill, 5d, Fill, 7d, Fill, 9d, Fill };
        var expectedValid = new[] { true, true, false, true, false, true, false, true, false };

        AssertShift("sequence.lead", Series, Available, Counts, 1d, Fill, expected, expectedValid);
    }

    /// <summary>Verifies the lag on chained rows, a gap, a series start, the head and an unavailable row, for k = 1.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void LagReadsThePreviousRowOnlyWhenChainedAndAvailable()
    {
        // Rows 0, 3 and 5 have no chained predecessor; row 8 follows the unavailable row 7.
        var expected = new[] { Fill, 1d, 2d, Fill, 4d, Fill, 6d, 7d, Fill };
        var expectedValid = new[] { false, true, true, false, true, false, true, true, false };

        AssertShift("sequence.lag", Series, Available, Counts, 1d, Fill, expected, expectedValid);
    }

    /// <summary>Verifies a lead of 2 needs both steps chained, and a lag of 2 needs the count to reach 2.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void OffsetTwoNeedsEveryStepChained()
    {
        // Lead: row 0 reaches row 2 over two chained steps; row 5 reaches the unavailable row 7; row 6 reaches row 8; every other row crosses
        // a gap or runs past the tail. Lag: rows 2, 7 and 8 have a count of at least 2.
        var leadValues = new[] { 3d, Fill, Fill, Fill, Fill, Fill, 9d, Fill, Fill };
        var leadValid = new[] { true, false, false, false, false, false, true, false, false };
        var lagValues = new[] { Fill, Fill, 1d, Fill, Fill, Fill, Fill, 6d, 7d };
        var lagValid = new[] { false, false, true, false, false, false, false, true, true };

        AssertShift("sequence.lead", Series, Available, Counts, 2d, Fill, leadValues, leadValid);
        AssertShift("sequence.lag", Series, Available, Counts, 2d, Fill, lagValues, lagValid);
    }

    /// <summary>Verifies k = 3 on a series that is one run, and on the broken series where only row 5 reaches row 8.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void OffsetThreeFollowsTheRuns()
    {
        var chained = Enumerable.Range(0, Series.Length).Select(index => (double)index).ToArray();
        var allAvailable = Enumerable.Repeat(true, Series.Length).ToArray();

        AssertShift("sequence.lead", Series, allAvailable, chained, 3d, Fill, [4d, 5d, 6d, 7d, 8d, 9d, Fill, Fill, Fill], [true, true, true, true, true, true, false, false, false]);
        AssertShift("sequence.lag", Series, allAvailable, chained, 3d, Fill, [Fill, Fill, Fill, 1d, 2d, 3d, 4d, 5d, 6d], [false, false, false, true, true, true, true, true, true]);
        AssertShift("sequence.lead", Series, Available, Counts, 3d, Fill, [Fill, Fill, Fill, Fill, Fill, 9d, Fill, Fill, Fill], [false, false, false, false, false, true, false, false, false]);
        AssertShift("sequence.lag", Series, Available, Counts, 3d, Fill, [Fill, Fill, Fill, Fill, Fill, Fill, Fill, Fill, 6d], [false, false, false, false, false, false, false, false, true]);
    }

    /// <summary>Verifies the series length, larger offsets and values far beyond int leave every row unavailable.</summary>
    [Theory]
    [Trait("Category", "BlockContract")]
    [InlineData(4d)]
    [InlineData(9d)]
    [InlineData(10d)]
    [InlineData(1000000d)]
    [InlineData(2147483648d)]
    [InlineData(1e300d)]
    public void LargeOffsetsLeaveEveryRowUnavailable(double k)
    {
        var allFalse = new bool[Series.Length];
        var allFill = Enumerable.Repeat(Fill, Series.Length).ToArray();
        var chained = Enumerable.Range(0, Series.Length).Select(index => (double)index).ToArray();
        var allAvailable = Enumerable.Repeat(true, Series.Length).ToArray();
        var broken = new[] { Fill, Fill, Fill, Fill, Fill, Fill, Fill, Fill, Fill };

        AssertShift("sequence.lead", Series, Available, Counts, k, Fill, broken, allFalse);
        AssertShift("sequence.lag", Series, Available, Counts, k, Fill, broken, allFalse);
        if (k >= 9d)
        {
            AssertShift("sequence.lead", Series, allAvailable, chained, k, Fill, allFill, allFalse);
            AssertShift("sequence.lag", Series, allAvailable, chained, k, Fill, allFill, allFalse);
        }
    }

    /// <summary>Verifies a series-long run read at its full width gives exactly one row, at either end.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void OffsetOfLengthMinusOneReadsTheEndRow()
    {
        var chained = Enumerable.Range(0, Series.Length).Select(index => (double)index).ToArray();
        var allAvailable = Enumerable.Repeat(true, Series.Length).ToArray();
        var leadValues = Enumerable.Repeat(Fill, Series.Length).ToArray();
        leadValues[0] = 9d;
        var leadValid = new bool[Series.Length];
        leadValid[0] = true;
        var lagValues = Enumerable.Repeat(Fill, Series.Length).ToArray();
        lagValues[8] = 1d;
        var lagValid = new bool[Series.Length];
        lagValid[8] = true;

        AssertShift("sequence.lead", Series, allAvailable, chained, 8d, Fill, leadValues, leadValid);
        AssertShift("sequence.lag", Series, allAvailable, chained, 8d, Fill, lagValues, lagValid);
    }

    /// <summary>Verifies an offset below 1 or a non-integer offset makes the whole call invalid, in every form.</summary>
    [Theory]
    [Trait("Category", "BlockContract")]
    [InlineData(0d)]
    [InlineData(-1d)]
    [InlineData(-2.5d)]
    [InlineData(0.5d)]
    [InlineData(1.5d)]
    [InlineData(2.0000000000000004d)]
    public void BadOffsetsAreWholeCallInvalid(double k)
    {
        foreach (var identifier in new[] { "sequence.lead", "sequence.lead-valid", "sequence.lag", "sequence.lag-valid" })
        {
            var result = Evaluate(identifier, Series, Available, Counts, k, Fill);

            Assert.False(result.IsValid, $"{identifier} accepted k = {k}.");
            Assert.Equal(identifier.EndsWith("-valid", StringComparison.Ordinal) ? MathBlockValueKind.BooleanVector : MathBlockValueKind.Vector, result.Type.Kind);
        }
    }

    /// <summary>Verifies a bad count, a count vector of another length or an availability vector of another length makes the whole call invalid.</summary>
    [Theory]
    [Trait("Category", "BlockContract")]
    [MemberData(nameof(Identities))]
    public void BadCountsAndLengthsAreWholeCallInvalid(string identifier)
    {
        Assert.False(Evaluate(identifier, Series, Available, WithCount(8, -1d), 1d, Fill).IsValid);
        Assert.False(Evaluate(identifier, Series, Available, WithCount(0, 0.5d), 1d, Fill).IsValid);
        Assert.False(Evaluate(identifier, Series, Available, WithCount(4, 1.0000000000000002d), 1d, Fill).IsValid);
        Assert.False(Evaluate(identifier, Series, Available, Counts[..8], 1d, Fill).IsValid);
        Assert.False(Evaluate(identifier, Series, Available, [.. Counts, 4d], 1d, Fill).IsValid);
        Assert.False(Evaluate(identifier, Series, Available[..8], Counts, 1d, Fill).IsValid);
        Assert.False(Evaluate(identifier, Series[..8], Available, Counts, 1d, Fill).IsValid);
        Assert.True(Evaluate(identifier, Series, Available, WithCount(4, 7d), 1d, Fill).IsValid);
    }

    /// <summary>Verifies a count above the row position, which a consistent series never has, cannot read before the start.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void InconsistentCountsNeverReadOutsideTheSeries()
    {
        var counts = new[] { 5d, 5d, 5d, 0d, 5d };
        var values = new[] { 1d, 2d, 3d, 4d, 5d };
        var available = new[] { true, true, true, true, true };

        AssertShift("sequence.lag", values, available, counts, 2d, Fill, [Fill, Fill, 1d, Fill, 3d], [false, false, true, false, true]);
        AssertShift("sequence.lead", values, available, counts, 2d, Fill, [3d, Fill, 5d, Fill, Fill], [true, false, true, false, false]);
    }

    /// <summary>Verifies the fill is returned unchanged, including a negative zero, and that signed zeros pass through bit for bit.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void FillAndSignedZerosKeepTheirBits()
    {
        double[] values = [-0d, 0d, -0d];
        bool[] available = [true, true, true];
        double[] counts = [0d, 1d, 2d];

        var lead = Evaluate("sequence.lead", values, available, counts, 1d, -0d).AsVector();
        var lag = Evaluate("sequence.lag", values, available, counts, 1d, -0d).AsVector();

        long[] expectedLead = [BitConverter.DoubleToInt64Bits(0d), BitConverter.DoubleToInt64Bits(-0d), BitConverter.DoubleToInt64Bits(-0d)];
        long[] expectedLag = [BitConverter.DoubleToInt64Bits(-0d), BitConverter.DoubleToInt64Bits(-0d), BitConverter.DoubleToInt64Bits(0d)];

        Assert.Equal(expectedLead, lead.Select(BitConverter.DoubleToInt64Bits));
        Assert.Equal(expectedLag, lag.Select(BitConverter.DoubleToInt64Bits));
    }

    /// <summary>Verifies every value form and its validity sibling agree with an independent reference on random runs, offsets and availability.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void FormsAgreeWithTheReferenceOnRandomSeries()
    {
        var random = new Random(0x1ead);
        for (var trial = 0; trial < 400; trial++)
        {
            var length = random.Next(1, 40);
            var values = new double[length];
            var available = new bool[length];
            var counts = new double[length];
            for (var index = 0; index < length; index++)
            {
                values[index] = random.Next(-50, 50) * 0.25d;
                available[index] = random.Next(5) != 0;
                counts[index] = index > 0 && random.Next(6) != 0 ? counts[index - 1] + 1d : 0d;
            }
            var offset = random.Next(1, length + 3);
            var fill = random.Next(-5, 5) * 1.5d;

            foreach (var lead in new[] { true, false })
            {
                var (expected, expectedValid) = Reference(lead, values, available, counts, offset, fill);
                AssertShift(lead ? "sequence.lead" : "sequence.lag", values, available, counts, offset, fill, expected, expectedValid);
            }
        }
    }

    /// <summary>Verifies the forms run inside a program, with the offset as an input, and give the same rows.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ProgramEvaluationMatchesTheOperation()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector(MathBlockUnit.Dimensionless, Series.Length));
        var flags = builder.Input("flags", MathBlockType.BooleanVector(Series.Length));
        var counts = builder.Input("counts", MathBlockType.Vector(MathBlockUnit.Dimensionless, Series.Length));
        var offset = builder.Input("offset", MathBlockType.Scalar());
        var fill = builder.Input("fill", MathBlockType.Scalar());
        var program = builder
            .Output("lead", builder.Apply("sequence.lead", 1, x, flags, counts, offset, fill))
            .Output("leadValid", builder.Apply("sequence.lead-valid", 1, x, flags, counts, offset))
            .Output("lag", builder.Apply("sequence.lag", 1, x, flags, counts, offset, fill))
            .Output("lagValid", builder.Apply("sequence.lag-valid", 1, x, flags, counts, offset))
            .Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector(Series),
            ["flags"] = MathBlockValue.BooleanVector(Available),
            ["counts"] = MathBlockValue.Vector(Counts),
            ["offset"] = MathBlockValue.Scalar(1d),
            ["fill"] = MathBlockValue.Scalar(Fill)
        };

        var outputs = program.Evaluate(inputs);

        Assert.True(Evaluate("sequence.lead", Series, Available, Counts, 1d, Fill).ApproximatelyEquals(outputs["lead"], 0d));
        Assert.True(Evaluate("sequence.lead-valid", Series, Available, Counts, 1d, Fill).ApproximatelyEquals(outputs["leadValid"], 0d));
        Assert.True(Evaluate("sequence.lag", Series, Available, Counts, 1d, Fill).ApproximatelyEquals(outputs["lag"], 0d));
        Assert.True(Evaluate("sequence.lag-valid", Series, Available, Counts, 1d, Fill).ApproximatelyEquals(outputs["lagValid"], 0d));
    }

    private static double[] WithCount(int index, double value)
    {
        var copy = (double[])Counts.Clone();
        copy[index] = value;
        return copy;
    }

    // The semantics of PatternResearcher's field reads, written from the rows' contiguity rather than from the counts' value: a
    // lead reads row t + k when each of the k steps from t is contiguous, a lag reads row t - k when each of the k steps ending at t is.
    private static (double[] Values, bool[] Valid) Reference(bool lead, double[] x, bool[] available, double[] counts, int offset, double fill)
    {
        var values = new double[x.Length];
        var valid = new bool[x.Length];
        for (var row = 0; row < x.Length; row++)
        {
            var target = lead ? row + offset : row - offset;
            var found = target >= 0 && target < x.Length && available[target];
            for (var step = 0; found && step < offset; step++)
                found = counts[lead ? row + step + 1 : row - step] >= 1d;
            values[row] = found ? x[target] : fill;
            valid[row] = found;
        }
        return (values, valid);
    }

    private static MathBlockValue Evaluate(string identifier, double[] x, bool[] available, double[] counts, double k, double fill)
    {
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var inputs = new List<MathBlockValue>
        {
            MathBlockValue.Vector(x),
            MathBlockValue.BooleanVector(available),
            MathBlockValue.Vector(counts),
            MathBlockValue.Scalar(k)
        };
        if (operation.Arity == 5)
            inputs.Add(MathBlockValue.Scalar(fill));
        return operation.Evaluate(inputs);
    }

    // Checks the value form and the validity sibling of one direction against the expected rows, bit for bit.
    private static void AssertShift(
        string identifier,
        double[] x,
        bool[] available,
        double[] counts,
        double k,
        double fill,
        double[] expected,
        bool[] expectedValid)
    {
        var value = Evaluate(identifier, x, available, counts, k, fill);
        var validity = Evaluate(identifier + "-valid", x, available, counts, k, fill);

        Assert.True(value.IsValid, $"{identifier} k={k}: {value.InvalidReason}");
        Assert.True(validity.IsValid, $"{identifier}-valid k={k}: {validity.InvalidReason}");
        Assert.Equal(expected.Select(BitConverter.DoubleToInt64Bits), value.AsVector().Select(BitConverter.DoubleToInt64Bits));
        Assert.Equal(expectedValid, validity.AsBooleanVector().ToArray());
    }
}
