using System.Diagnostics;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the CoreCLR window forms and their validity siblings.</summary>
public sealed class MathBlockWindowFormTests
{
    private const float Sentinel = 12_345.5f;

    /// <summary>Gets every source identifier of the window forms.</summary>
    public static TheoryData<string> Sources => [.. SourceIdentifiers];

    /// <summary>Gets every window form and validity sibling identity.</summary>
    public static TheoryData<string> Identities =>
        [.. Windowed.Operations.Select(operation => operation.Identity)];

    /// <summary>
    /// Verifies the window registry holds exactly the 53 design forms, the six accurate forms and their siblings, and
    /// that Standard registers the same instances.
    /// </summary>
    [Fact]
    public void WindowRegistryHoldsTheDesignFormsAndSiblingsInStandard()
    {
        Assert.Equal(53, SourceIdentifiers.Length);
        Assert.Equal(53, SourceIdentifiers.Distinct(StringComparer.Ordinal).Count());
        var expected = SourceIdentifiers
            .SelectMany(source => new[] { $"window.{source}@1", $"window-valid.{source}@1" })
            .Concat(MathBlockWindowM2TestSupport.AccurateNames
                .SelectMany(name => new[] { $"window-accurate.{name}@1", $"window-accurate-valid.{name}@1" }))
            .Order(StringComparer.Ordinal);
        Assert.Equal(expected, Windowed.Operations.Select(operation => operation.Identity), StringComparer.Ordinal);
        foreach (var source in SourceIdentifiers)
        {
            var arity = MathBlockCatalog.Standard.Get(source).Arity;
            Assert.Equal(arity + 2, Form(source).Arity);
            Assert.Equal(arity + 1, Validity(source).Arity);
        }

        Assert.All(Windowed.Operations, operation =>
            Assert.Same(operation, MathBlockCatalog.Standard.Get(operation.Identifier, operation.Version)));
    }

    /// <summary>Checks each window operation's regression and performance contract on CoreCLR.</summary>
    [Theory]
    [MemberData(nameof(Identities))]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var separator = identity.LastIndexOf('@');
        var operation = Windowed.Get(identity[..separator]);

        Assert.Equal(identity, operation.Identity);
        Assert.NotEmpty(operation.RegressionCases);
        Assert.Equal(operation.Arity, operation.PerformanceCase.Inputs.Count);
        Assert.InRange(operation.PerformanceCase.MaximumWarmLatencyMicroseconds, float.Epsilon, 1_000f);
        foreach (var regression in operation.RegressionCases)
        {
            var actual = operation.Evaluate(regression.Inputs);
            Assert.True(
                actual.ApproximatelyEquals(regression.Expected, regression.Tolerance),
                $"{identity}/{regression.Name} did not match its regression result.");
        }

        var inputs = operation.PerformanceCase.Inputs.ToArray();
        var copies = inputs.Select(input => input.Type.Kind switch
        {
            MathBlockValueKind.Vector => input.AsVector().ToArray(),
            MathBlockValueKind.BooleanVector => input.AsBooleanVector().ToArray().Select(flag => flag ? 1f : 0f).ToArray(),
            MathBlockValueKind.Boolean => [input.AsBoolean() ? 1f : 0f],
            _ => [input.AsScalar()]
        }).ToArray();
        var first = operation.Evaluate(inputs);
        var second = operation.Evaluate(inputs);
        Assert.True(first.ApproximatelyEquals(second, 0f), $"{identity}: repeated outputs differ.");
        for (var index = 0; index < inputs.Length; index++)
        {
            var after = inputs[index].Type.Kind switch
            {
                MathBlockValueKind.Vector => inputs[index].AsVector().ToArray(),
                MathBlockValueKind.BooleanVector => inputs[index].AsBooleanVector().ToArray().Select(flag => flag ? 1f : 0f).ToArray(),
                MathBlockValueKind.Boolean => [inputs[index].AsBoolean() ? 1f : 0f],
                _ => [inputs[index].AsScalar()]
            };
            Assert.Equal(copies[index], after);
        }

        for (var warmup = 0; warmup < 64; warmup++)
            _ = operation.Evaluate(operation.PerformanceCase.Inputs);
        const int batchCount = 101;
        var samples = new float[batchCount];
        for (var batch = 0; batch < batchCount; batch++)
        {
            var started = Stopwatch.GetTimestamp();
            for (var iteration = 0; iteration < operation.PerformanceCase.Iterations; iteration++)
                _ = operation.Evaluate(operation.PerformanceCase.Inputs);
            samples[batch] = (float)Stopwatch.GetElapsedTime(started).TotalMilliseconds * 1_000f /
                             operation.PerformanceCase.Iterations;
        }
        Array.Sort(samples);
        Assert.True(
            samples[95] < operation.PerformanceCase.MaximumWarmLatencyMicroseconds,
            $"{identity} warm p95 was {samples[95]:F3} microseconds.");
    }

    /// <summary>
    /// Verifies every row equals the source on its window bit for bit, and the sibling marks exactly the computed
    /// rows, with the fill set to a sentinel and to a value that also occurs as a computed result.
    /// </summary>
    [Theory]
    [MemberData(nameof(Sources))]
    public void SmallSeriesRowsEqualTheSourceOnEachWindowBitForBit(string source)
    {
        const int count = 40;
        var seed = 7_000 + Array.IndexOf(SourceIdentifiers, source);
        var failures = new List<string>();
        foreach (var width in new[] { 1, 2, 3, 17, count })
        {
            var sourceInputs = CreateSourceInputs(source, count, width, seed + width);
            var reference = Reference(source, sourceInputs, count, width);
            var unit = Form(source).ResolveOutputType(
                [.. sourceInputs.Select(input => input.Type), MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
            var realValue = Sentinel;
            for (var row = 0; row < count; row++)
            {
                if (reference.Valid[row])
                {
                    realValue = reference.Values[row];
                    break;
                }
            }
            var validity = Validity(source).Evaluate(ValidityInputs(sourceInputs, width));
            foreach (var fill in new[] { Sentinel, realValue })
            {
                var form = Form(source).Evaluate(FormInputs(sourceInputs, width, MathBlockValue.Scalar(fill, unit)));
                failures.AddRange(Compare(source, width, fill, form, validity, reference));
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>Verifies warm-up rows and a source-invalid window hold the fill and are marked not computed.</summary>
    [Fact]
    public void WarmUpRowsAndSourceInvalidWindowsHoldTheFillAndAreMarkedFalse()
    {
        var x = MathBlockValue.Vector([1f, 1f, 1f, 2f, 4f]);
        var y = MathBlockValue.Vector([1f, 2f, 3f, 4f, 6f]);
        var pearson = MathBlockCatalog.Standard.Get("statistics.pearson-correlation");

        var form = Form("statistics.pearson-correlation").Evaluate(x, y, MathBlockValue.Scalar(3f), MathBlockValue.Scalar(9f));
        var validity = Validity("statistics.pearson-correlation").Evaluate(x, y, MathBlockValue.Scalar(3f));

        Assert.False(pearson.Evaluate(MathBlockValue.Vector([1f, 1f, 1f]), MathBlockValue.Vector([1f, 2f, 3f])).IsValid);
        var values = form.AsVector();
        Assert.Equal(9f, values[0]);
        Assert.Equal(9f, values[1]);
        Assert.Equal(9f, values[2]);
        Assert.Equal(
            pearson.Evaluate(MathBlockValue.Vector([1f, 1f, 2f]), MathBlockValue.Vector([2f, 3f, 4f])).AsScalar(),
            values[3]);
        Assert.Equal(
            pearson.Evaluate(MathBlockValue.Vector([1f, 2f, 4f]), MathBlockValue.Vector([3f, 4f, 6f])).AsScalar(),
            values[4]);
        Assert.Equal([false, false, false, true, true], validity.AsBooleanVector().ToArray());
    }

    /// <summary>Verifies window position forms return the in-window position with the source tie rule.</summary>
    [Fact]
    public void ArgumentFormsReturnTheInWindowPositionWithTheSourceTieRule()
    {
        var values = MathBlockValue.Vector([3f, 1f, 3f, 2f, 1f, 5f]);
        var width = MathBlockValue.Scalar(3f);
        var fill = MathBlockValue.Scalar(-1f);

        Assert.Equal(
            [-1f, -1f, 0f, 1f, 0f, 2f],
            Form("vector.arg-maximum").Evaluate(values, width, fill).AsVector().ToArray());
        Assert.Equal(
            [-1f, -1f, 1f, 0f, 2f, 1f],
            Form("vector.arg-minimum").Evaluate(values, width, fill).AsVector().ToArray());
    }

    /// <summary>Verifies width one and width equal to the length are computed, and width beyond it is invalid.</summary>
    [Fact]
    public void WidthBoundsAndNonIntegerWidthsFollowTheSeriesDomain()
    {
        var values = MathBlockValue.Vector([4f, 1f, 3f, 2f]);
        var fill = MathBlockValue.Scalar(0f);
        var mean = Form("vector.mean");
        var meanValidity = Validity("vector.mean");

        Assert.Equal([4f, 1f, 3f, 2f], mean.Evaluate(values, MathBlockValue.Scalar(1f), fill).AsVector().ToArray());
        Assert.Equal([0f, 0f, 0f, 2.5f], mean.Evaluate(values, MathBlockValue.Scalar(4f), fill).AsVector().ToArray());
        Assert.Equal(
            [false, false, false, true],
            meanValidity.Evaluate(values, MathBlockValue.Scalar(4f)).AsBooleanVector().ToArray());
        foreach (var width in new[] { 5f, 0f, -1f, 2.5f, 1e12f })
        {
            Assert.False(mean.Evaluate(values, MathBlockValue.Scalar(width), fill).IsValid, $"width {width}");
            Assert.False(meanValidity.Evaluate(values, MathBlockValue.Scalar(width)).IsValid, $"width {width}");
        }
        Assert.False(mean.Evaluate(MathBlockValue.Vector([]), MathBlockValue.Scalar(1f), fill).IsValid);
    }

    /// <summary>Verifies unequal series lengths, invalid inputs and nonfinite fills give an invalid output.</summary>
    [Fact]
    public void UnequalLengthsInvalidInputsAndNonfiniteFillsAreInvalid()
    {
        var x = MathBlockValue.Vector([1f, 2f, 4f, 3f]);
        var shorter = MathBlockValue.Vector([1f, 2f, 4f]);
        var width = MathBlockValue.Scalar(2f);
        var fill = MathBlockValue.Scalar(0f);

        var unequal = Form("statistics.pearson-correlation").Evaluate(x, shorter, width, fill);
        Assert.False(unequal.IsValid);
        Assert.Equal("The window series lengths differ.", unequal.InvalidReason);
        Assert.False(Validity("statistics.pearson-correlation").Evaluate(x, shorter, width).IsValid);
        Assert.False(Form("statistics.weighted-mean").Evaluate(x, shorter, width, fill).IsValid);
        foreach (var nonfinite in new[] { float.NaN, float.PositiveInfinity, float.NegativeInfinity })
            Assert.False(Form("vector.sum").Evaluate(x, width, MathBlockValue.Scalar(nonfinite)).IsValid);
        var invalidInput = MathBlockValue.Invalid(MathBlockType.Vector(), "upstream");
        Assert.False(Form("vector.sum").Evaluate(invalidInput, width, fill).IsValid);
        Assert.False(Validity("vector.sum").Evaluate(invalidInput, width).IsValid);
    }

    /// <summary>Verifies the declared output types carry the source unit, the series length and the fill rule.</summary>
    [Fact]
    public void DeclaredTypesCarryTheSourceUnitLengthAndFillUnit()
    {
        var unit = MathBlockUnit.Basis0;
        var series = MathBlockType.Vector(unit, 6);
        var width = MathBlockType.Scalar();

        Assert.Equal(
            MathBlockType.Vector(unit, 6),
            Form("vector.mean").ResolveOutputType([series, width, MathBlockType.Scalar(unit)]));
        Assert.Equal(
            MathBlockType.Vector(unit.Pow(new MathRational(2)), 6),
            Form("statistics.population-variance").ResolveOutputType(
                [series, width, MathBlockType.Scalar(unit.Pow(new MathRational(2)))]));
        Assert.Equal(
            MathBlockType.BooleanVector(6),
            Validity("statistics.linear-slope").ResolveOutputType([series, series, width]));
        Assert.Equal(
            MathBlockType.Vector(length: 0),
            Form("statistics.pearson-correlation").ResolveOutputType(
                [series, MathBlockType.Vector(unit, 5), width, MathBlockType.Scalar()]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("vector.mean").ResolveOutputType([series, width, MathBlockType.Scalar()]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("vector.mean").ResolveOutputType([series, MathBlockType.Scalar(unit), MathBlockType.Scalar(unit)]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("vector.mean").ResolveOutputType([MathBlockType.Scalar(unit), width, MathBlockType.Scalar(unit)]));

        var meters = MathBlockValue.Vector([1f, 2f, 4f], unit);
        var result = Form("vector.mean").Evaluate(meters, MathBlockValue.Scalar(2f), MathBlockValue.Scalar(0f, unit));
        Assert.Equal(MathBlockType.Vector(unit, 3), result.Type);
        Assert.Equal([0f, 1.5f, 3f], result.AsVector().ToArray());
    }

    /// <summary>Verifies concurrent evaluations of one form are independent and identical.</summary>
    [Fact]
    public void ConcurrentEvaluationsAreIndependentAndIdentical()
    {
        const int count = 2_000;
        var forms = new[] { "statistics.spearman-correlation", "vector.rank", "path.longest-true-run" };
        foreach (var source in forms)
        {
            var sourceInputs = CreateSourceInputs(source, count, 24, 99);
            var inputs = FormInputs(sourceInputs, 24, MathBlockValue.Scalar(Sentinel));
            var expected = Form(source).Evaluate(inputs).AsVector().ToArray();
            var results = new float[8][];
            Parallel.For(0, results.Length, new ParallelOptions { MaxDegreeOfParallelism = 4 }, index =>
                results[index] = Form(source).Evaluate(inputs).AsVector().ToArray());
            foreach (var result in results)
                Assert.Equal(expected.Select(BitConverter.SingleToInt32Bits), result.Select(BitConverter.SingleToInt32Bits));
        }
    }
}
