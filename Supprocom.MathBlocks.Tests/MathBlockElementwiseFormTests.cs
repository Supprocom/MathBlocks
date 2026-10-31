using System.Diagnostics;
using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the CoreCLR elementwise forms and their validity siblings.</summary>
public sealed class MathBlockElementwiseFormTests
{
    private const double Sentinel = 12_345.5d;

    /// <summary>Gets every source identifier of the elementwise forms.</summary>
    public static TheoryData<string> Sources => [.. SourceIdentifiers];

    /// <summary>Gets every elementwise form and validity sibling identity.</summary>
    public static TheoryData<string> Identities =>
        [.. Elementwise.Operations.Select(operation => operation.Identity)];

    /// <summary>
    /// Verifies the registry holds exactly one form and one sibling per scalar-only Standard operation that has no
    /// Pointwise vector form of the same name, outside Standard.
    /// </summary>
    [Fact]
    public void ElementwiseRegistryHoldsTheDesignFormsAndSiblingsOutsideStandard()
    {
        var standard = MathBlockCatalog.Standard.Operations;
        var scalarOnly = standard
            .Where(operation =>
                operation.RegressionCases.Select(regression => regression.Inputs)
                    .Append(operation.PerformanceCase.Inputs)
                    .All(inputs => inputs.All(input => input.Type.Kind == MathBlockValueKind.Scalar)) &&
                operation.RegressionCases.All(regression => regression.Expected.Type.Kind == MathBlockValueKind.Scalar))
            .Select(operation => operation.Identifier)
            .ToArray();
        bool HasVectorForm(string identifier)
        {
            var name = identifier[(identifier.IndexOf('.', StringComparison.Ordinal) + 1)..];
            var vector = standard.FirstOrDefault(operation =>
                string.Equals(operation.Identifier, $"vector.{name}", StringComparison.Ordinal));
            return vector is not null &&
                   vector.Causality.Kind == MathBlockCausality.Pointwise &&
                   vector.RegressionCases.All(regression => regression.Expected.Type.Kind == MathBlockValueKind.Vector);
        }

        Assert.Equal(53, scalarOnly.Length);
        Assert.Equal(
            [
                "scalar.absolute", "scalar.add", "scalar.divide", "scalar.exponential", "scalar.multiply",
                "scalar.natural-logarithm", "scalar.positive-part", "scalar.power", "scalar.sign",
                "scalar.square", "scalar.square-root", "scalar.subtract"
            ],
            scalarOnly.Where(HasVectorForm).Order(StringComparer.Ordinal),
            StringComparer.Ordinal);
        Assert.Equal(41, SourceIdentifiers.Length);
        Assert.Equal(scalarOnly.Where(identifier => !HasVectorForm(identifier)), SourceIdentifiers, StringComparer.Ordinal);

        var expected = SourceIdentifiers
            .SelectMany(source => new[] { $"elementwise.{source}@1", $"elementwise-valid.{source}@1" })
            .Order(StringComparer.Ordinal);
        Assert.Equal(expected, Elementwise.Operations.Select(operation => operation.Identity), StringComparer.Ordinal);
        foreach (var source in SourceIdentifiers)
        {
            Assert.Equal(SourceArity(source) + 1, Form(source).Arity);
            Assert.Equal(SourceArity(source), Validity(source).Arity);
        }

        Assert.Equal(337, standard.Count);
        Assert.DoesNotContain(
            standard,
            operation => operation.Identifier.StartsWith("elementwise", StringComparison.Ordinal));
    }

    /// <summary>Checks each elementwise operation's regression and performance contract on CoreCLR.</summary>
    [Theory]
    [MemberData(nameof(Identities))]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var separator = identity.LastIndexOf('@');
        var operation = Elementwise.Get(identity[..separator]);

        Assert.Equal(identity, operation.Identity);
        Assert.NotEmpty(operation.RegressionCases);
        Assert.Equal(operation.Arity, operation.PerformanceCase.Inputs.Count);
        Assert.InRange(operation.PerformanceCase.MaximumWarmLatencyMicroseconds, double.Epsilon, 1_000d);
        foreach (var regression in operation.RegressionCases)
        {
            var actual = operation.Evaluate(regression.Inputs);
            Assert.True(
                actual.ApproximatelyEquals(regression.Expected, regression.Tolerance),
                $"{identity}/{regression.Name} did not match its regression result.");
        }

        var inputs = operation.PerformanceCase.Inputs.ToArray();
        var copies = inputs.Select(input => input.Type.Kind == MathBlockValueKind.Vector
            ? input.AsVector().ToArray()
            : [input.AsScalar()]).ToArray();
        var first = operation.Evaluate(inputs);
        var second = operation.Evaluate(inputs);
        Assert.True(first.ApproximatelyEquals(second, 0d), $"{identity}: repeated outputs differ.");
        for (var index = 0; index < inputs.Length; index++)
        {
            var after = inputs[index].Type.Kind == MathBlockValueKind.Vector
                ? inputs[index].AsVector().ToArray()
                : [inputs[index].AsScalar()];
            Assert.Equal(copies[index], after);
        }

        for (var warmup = 0; warmup < 64; warmup++)
            _ = operation.Evaluate(operation.PerformanceCase.Inputs);
        const int batchCount = 101;
        var samples = new double[batchCount];
        for (var batch = 0; batch < batchCount; batch++)
        {
            var started = Stopwatch.GetTimestamp();
            for (var iteration = 0; iteration < operation.PerformanceCase.Iterations; iteration++)
                _ = operation.Evaluate(operation.PerformanceCase.Inputs);
            samples[batch] = Stopwatch.GetElapsedTime(started).TotalMilliseconds * 1_000d /
                             operation.PerformanceCase.Iterations;
        }
        Array.Sort(samples);
        Assert.True(
            samples[95] < operation.PerformanceCase.MaximumWarmLatencyMicroseconds,
            $"{identity} warm p95 was {samples[95]:F3} microseconds.");
    }

    /// <summary>
    /// Verifies every row equals the source on that row's arguments bit for bit, for every vector or scalar
    /// choice per argument, and the sibling marks exactly the computed rows, with the fill set to a sentinel and to
    /// a value that also occurs as a computed result.
    /// </summary>
    [Theory]
    [MemberData(nameof(Sources))]
    public void SmallVectorRowsEqualTheSourceOnEachRowBitForBit(string source)
    {
        var failures = new List<string>();
        var computed = 0;
        var filled = 0;
        var seed = 9_000 + 64 * Array.IndexOf(SourceIdentifiers, source);
        foreach (var mask in BroadcastMasks(source))
        {
            foreach (var count in new[] { 1, 2, 7, 257 })
            {
                for (var trial = 0; trial < 3; trial++)
                {
                    var arguments = CreateArguments(source, count, mask, seed++);
                    var reference = Reference(source, arguments);
                    computed += reference.Valid.Count(flag => flag);
                    filled += reference.Valid.Count(flag => !flag);
                    var realValue = Sentinel;
                    for (var row = 0; row < count; row++)
                    {
                        if (reference.Valid[row])
                        {
                            realValue = reference.Values[row];
                            break;
                        }
                    }
                    var validity = Validity(source).Evaluate(arguments);
                    foreach (var fill in new[] { Sentinel, realValue })
                    {
                        var form = Form(source).Evaluate([.. arguments, MathBlockValue.Scalar(fill)]);
                        var label = $"{source} [{DescribeMask(source, mask)}] n={count} seed={seed - 1} fill={fill:R}";
                        failures.AddRange(Compare(label, fill, form, validity, reference));
                    }
                }
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
        Assert.True(computed > 0, $"{source}: no row was computed.");
        Assert.True(computed + filled > 0, $"{source}: no row was checked.");
    }

    /// <summary>Verifies every elementwise operation is labelled Pointwise and the label holds under perturbation.</summary>
    [Theory]
    [MemberData(nameof(Identities))]
    [Trait("Category", "CausalityContract")]
    public void CausalityIsPointwiseAndHoldsUnderPerturbation(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var operation = Elementwise.Get(identity[..identity.LastIndexOf('@')]);

        Assert.Equal(MathBlockCausality.Pointwise, operation.Causality.Kind);
        Assert.Null(operation.Causality.WidthInputIndex);
        var failures = MathBlockCausalityChecks.Check(operation);
        Assert.True(failures.Count == 0, MathBlockCausalityChecks.Format(failures));
    }

    /// <summary>
    /// Applies the causality perturbation check directly with each source's own value mix, for every vector or
    /// scalar choice per argument: perturbing every other row leaves row t of the form and the sibling bit for bit
    /// unchanged, and perturbing row t itself changes it in some trial, so the check is not vacuous. The M5 check
    /// above draws from fixed domains, on which an integer-only source fills every row.
    /// </summary>
    [Theory]
    [MemberData(nameof(Sources))]
    [Trait("Category", "CausalityContract")]
    public void EachRowDependsOnlyOnItsOwnArgumentRow(string source)
    {
        const int count = 48;
        var failures = new List<string>();
        var ownRowChanges = 0;
        var seed = 17_000 + 64 * Array.IndexOf(SourceIdentifiers, source);
        foreach (var mask in BroadcastMasks(source))
        {
            for (var trial = 0; trial < 4; trial++)
            {
                var random = new Random(seed++);
                var arguments = CreateArguments(source, count, mask, random.Next());
                var form = Form(source).Evaluate([.. arguments, MathBlockValue.Scalar(Sentinel)]).AsVector();
                var flags = Validity(source).Evaluate(arguments).AsBooleanVector();
                var computedRows = Enumerable.Range(0, count).Where(row => flags[row]).ToArray();
                for (var pick = 0; pick < 6; pick++)
                {
                    // Half of the picks are computed rows, so sources that fill most rows are still checked.
                    var row = pick % 2 == 0 && computedRows.Length > 0
                        ? computedRows[random.Next(computedRows.Length)]
                        : random.Next(count);
                    var others = Perturb(source, arguments, other => other != row, random);
                    var otherForm = Form(source).Evaluate([.. others, MathBlockValue.Scalar(Sentinel)]).AsVector();
                    var otherFlags = Validity(source).Evaluate(others).AsBooleanVector();
                    if (BitConverter.DoubleToInt64Bits(otherForm[row]) != BitConverter.DoubleToInt64Bits(form[row]) ||
                        otherFlags[row] != flags[row])
                    {
                        failures.Add($"{source} [{DescribeMask(source, mask)}] row {row} changed when every other row was perturbed: " +
                                     $"{form[row]:R}/{flags[row]} became {otherForm[row]:R}/{otherFlags[row]}.");
                    }
                    var own = Perturb(source, arguments, other => other == row, random);
                    var ownForm = Form(source).Evaluate([.. own, MathBlockValue.Scalar(Sentinel)]).AsVector();
                    if (BitConverter.DoubleToInt64Bits(ownForm[row]) != BitConverter.DoubleToInt64Bits(form[row]))
                        ownRowChanges++;
                }
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(8)));
        Assert.True(ownRowChanges > 0, $"{source}: perturbing a row never changed that row.");
    }

    /// <summary>Verifies source-invalid rows hold the fill and are marked false, including a fill equal to a real row.</summary>
    [Fact]
    public void SourceInvalidRowsHoldTheFillAndTheSiblingTellsThemApart()
    {
        var values = MathBlockValue.Vector([0.25d, 0d, 0.5d, 1d, 2d, -1d]);
        var form = Form("scalar.logit");
        var validity = Validity("scalar.logit");
        var logit = MathBlockCatalog.Standard.Get("scalar.logit");

        Assert.False(logit.Evaluate(MathBlockValue.Scalar(1d)).IsValid);
        Assert.Equal(0d, logit.Evaluate(MathBlockValue.Scalar(0.5d)).AsScalar());
        var result = form.Evaluate(values, MathBlockValue.Scalar(0d)).AsVector().ToArray();
        Assert.Equal(logit.Evaluate(MathBlockValue.Scalar(0.25d)).AsScalar(), result[0]);
        Assert.Equal([0d, 0d, 0d, 0d, 0d], result[1..]);
        Assert.Equal([true, false, true, false, false, false], validity.Evaluate(values).AsBooleanVector().ToArray());
    }

    /// <summary>Verifies signed zeros and subnormal rows keep the source's bits.</summary>
    [Fact]
    public void SignedZerosAndSubnormalsKeepTheSourceBits()
    {
        var fill = MathBlockValue.Scalar(7d);
        var negated = Form("scalar.negate")
            .Evaluate(MathBlockValue.Vector([0d, double.NegativeZero, double.Epsilon, -1e-310d]), fill)
            .AsVector().ToArray();
        Assert.Equal(
            new[] { double.NegativeZero, 0d, -double.Epsilon, 1e-310d }.Select(BitConverter.DoubleToInt64Bits),
            negated.Select(BitConverter.DoubleToInt64Bits));

        var rounded = Form("scalar.round")
            .Evaluate(MathBlockValue.Vector([-0.5d, 0.5d, -1e-310d]), fill)
            .AsVector().ToArray();
        Assert.Equal(
            new[] { double.NegativeZero, 0d, double.NegativeZero }.Select(BitConverter.DoubleToInt64Bits),
            rounded.Select(BitConverter.DoubleToInt64Bits));

        var sine = Form("scalar.sine").Evaluate(MathBlockValue.Vector([double.NegativeZero, -double.Epsilon]), fill);
        var source = MathBlockCatalog.Standard.Get("scalar.sine");
        Assert.Equal(
            new[] { double.NegativeZero, -double.Epsilon }
                .Select(value => BitConverter.DoubleToInt64Bits(source.Evaluate(MathBlockValue.Scalar(value)).AsScalar())),
            sine.AsVector().ToArray().Select(BitConverter.DoubleToInt64Bits));
    }

    /// <summary>Verifies empty vectors give valid empty outputs.</summary>
    [Fact]
    public void EmptyVectorsGiveValidEmptyOutputs()
    {
        var empty = MathBlockValue.Vector([]);
        var fill = MathBlockValue.Scalar(0d);

        var unary = Form("scalar.sine").Evaluate(empty, fill);
        Assert.True(unary.IsValid);
        Assert.Equal(MathBlockType.Vector(length: 0), unary.Type);
        Assert.Empty(unary.AsVector());
        var flags = Validity("scalar.sine").Evaluate(empty);
        Assert.True(flags.IsValid);
        Assert.Empty(flags.AsBooleanVector());

        var binary = Form("scalar.arc-tangent-2").Evaluate(empty, MathBlockValue.Scalar(1d), fill);
        Assert.True(binary.IsValid);
        Assert.Empty(binary.AsVector());
        Assert.True(Form("scalar.arc-tangent-2").Evaluate(empty, empty, fill).IsValid);
        Assert.False(Form("scalar.arc-tangent-2").Evaluate(empty, MathBlockValue.Vector([1d]), fill).IsValid);
    }

    /// <summary>Verifies unequal vector lengths, invalid inputs and nonfinite fills give an invalid output.</summary>
    [Fact]
    public void UnequalLengthsInvalidInputsAndNonfiniteFillsAreInvalid()
    {
        var x = MathBlockValue.Vector([1d, 2d, 4d, 3d]);
        var shorter = MathBlockValue.Vector([1d, 2d, 4d]);
        var fill = MathBlockValue.Scalar(0d);

        var unequal = Form("scalar.arc-tangent-2").Evaluate(x, shorter, fill);
        Assert.False(unequal.IsValid);
        Assert.Equal("The elementwise vector lengths differ.", unequal.InvalidReason);
        Assert.False(Validity("scalar.arc-tangent-2").Evaluate(x, shorter).IsValid);
        Assert.False(Form("scalar.clamp").Evaluate(x, MathBlockValue.Scalar(0d), shorter, fill).IsValid);
        Assert.False(Validity("special.regularized-incomplete-beta").Evaluate(shorter, x, x).IsValid);
        foreach (var nonfinite in new[] { double.NaN, double.PositiveInfinity, double.NegativeInfinity })
        {
            Assert.False(Form("scalar.sine").Evaluate(x, MathBlockValue.Scalar(nonfinite)).IsValid);
            Assert.False(Form("scalar.maximum").Evaluate(x, MathBlockValue.Scalar(1d), MathBlockValue.Scalar(nonfinite)).IsValid);
        }
        var invalidVector = MathBlockValue.Invalid(MathBlockType.Vector(), "upstream");
        var invalidScalar = MathBlockValue.Invalid(MathBlockType.Scalar(), "upstream");
        Assert.False(Form("scalar.sine").Evaluate(invalidVector, fill).IsValid);
        Assert.False(Validity("scalar.sine").Evaluate(invalidVector).IsValid);
        Assert.False(Form("scalar.maximum").Evaluate(x, invalidScalar, fill).IsValid);
        Assert.False(Validity("scalar.maximum").Evaluate(x, invalidScalar).IsValid);
    }

    /// <summary>Verifies all-scalar arguments and other kinds are rejected by type.</summary>
    [Fact]
    public void AllScalarArgumentsAndNonVectorKindsAreRejectedByType()
    {
        var scalar = MathBlockType.Scalar();

        Assert.Throws<InvalidOperationException>(() => Form("scalar.sine").ResolveOutputType([scalar, scalar]));
        Assert.Throws<InvalidOperationException>(() => Validity("scalar.sine").ResolveOutputType([scalar]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("scalar.clamp").ResolveOutputType([scalar, scalar, scalar, scalar]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("scalar.sine").Evaluate(MathBlockValue.Scalar(1d), MathBlockValue.Scalar(0d)));
        Assert.Throws<InvalidOperationException>(() =>
            Validity("scalar.arc-tangent-2").Evaluate(MathBlockValue.Scalar(1d), MathBlockValue.Scalar(1d)));
        Assert.Throws<InvalidOperationException>(() =>
            Form("scalar.sine").ResolveOutputType([MathBlockType.BooleanVector(3), scalar]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("scalar.sine").ResolveOutputType([MathBlockType.Matrix(rows: 2, columns: 2), scalar]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("scalar.sine").ResolveOutputType([MathBlockType.Vector(length: 3), MathBlockType.Vector(length: 3)]));
    }

    /// <summary>Verifies the declared output types carry the source unit, the vector length and the fill rule.</summary>
    [Fact]
    public void DeclaredTypesCarryTheSourceUnitLengthAndFillUnit()
    {
        var unit = MathBlockUnit.Basis0;
        var series = MathBlockType.Vector(unit, 6);

        Assert.Equal(
            MathBlockType.Vector(unit, 6),
            Form("scalar.maximum").ResolveOutputType([series, MathBlockType.Scalar(unit), MathBlockType.Scalar(unit)]));
        Assert.Equal(
            MathBlockType.Vector(unit, 6),
            Form("scalar.negate").ResolveOutputType([series, MathBlockType.Scalar(unit)]));
        Assert.Equal(
            MathBlockType.Vector(length: 6),
            Form("scalar.sine").ResolveOutputType([MathBlockType.Vector(length: 6), MathBlockType.Scalar()]));
        Assert.Equal(
            MathBlockType.BooleanVector(6),
            Validity("scalar.clamp").ResolveOutputType([MathBlockType.Scalar(unit), series, series]));
        Assert.Equal(
            MathBlockType.Vector(unit, 0),
            Form("scalar.minimum").ResolveOutputType([series, MathBlockType.Vector(unit, 5), MathBlockType.Scalar(unit)]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("scalar.maximum").ResolveOutputType([series, MathBlockType.Scalar(unit), MathBlockType.Scalar()]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("scalar.maximum").ResolveOutputType([series, MathBlockType.Scalar(), MathBlockType.Scalar(unit)]));
        Assert.Throws<InvalidOperationException>(() =>
            Form("scalar.sine").ResolveOutputType([series, MathBlockType.Scalar(unit)]));

        var meters = MathBlockValue.Vector([1d, -2d, 4d], unit);
        var result = Form("scalar.maximum").Evaluate(meters, MathBlockValue.Scalar(0d, unit), MathBlockValue.Scalar(-1d, unit));
        Assert.Equal(MathBlockType.Vector(unit, 3), result.Type);
        Assert.Equal([1d, 0d, 4d], result.AsVector().ToArray());
    }

    /// <summary>
    /// Verifies a clamp row with the lower limit above the upper limit throws as the scalar source does: the
    /// CoreCLR scalar.clamp evaluator calls Math.Clamp, which throws ArgumentException instead of returning an
    /// invalid result.
    /// </summary>
    [Fact]
    public void ClampWithLowerAboveUpperThrowsAsTheSourceDoes()
    {
        var clamp = MathBlockCatalog.Standard.Get("scalar.clamp");
        Assert.Throws<ArgumentException>(() =>
            clamp.Evaluate(MathBlockValue.Scalar(1d), MathBlockValue.Scalar(3d), MathBlockValue.Scalar(2d)));
        Assert.Throws<ArgumentException>(() => Form("scalar.clamp").Evaluate(
            MathBlockValue.Vector([1d, 2d]),
            MathBlockValue.Vector([0d, 3d]),
            MathBlockValue.Scalar(2d),
            MathBlockValue.Scalar(0d)));
    }

    /// <summary>Verifies concurrent evaluations of one form are independent and identical.</summary>
    [Fact]
    public void ConcurrentEvaluationsAreIndependentAndIdentical()
    {
        const int count = 4_000;
        foreach (var source in new[] { "special.regularized-incomplete-beta", "scalar.logit", "scalar.modulo" })
        {
            var mask = (1 << SourceArity(source)) - 1;
            var arguments = CreateArguments(source, count, mask, 99);
            MathBlockValue[] inputs = [.. arguments, MathBlockValue.Scalar(Sentinel)];
            var expected = Form(source).Evaluate(inputs).AsVector().ToArray();
            var expectedFlags = Validity(source).Evaluate(arguments).AsBooleanVector().ToArray();
            var results = new double[8][];
            var flags = new bool[8][];
            Parallel.For(0, results.Length, new ParallelOptions { MaxDegreeOfParallelism = 4 }, index =>
            {
                results[index] = Form(source).Evaluate(inputs).AsVector().ToArray();
                flags[index] = Validity(source).Evaluate(arguments).AsBooleanVector().ToArray();
            });
            foreach (var result in results)
                Assert.Equal(expected.Select(BitConverter.DoubleToInt64Bits), result.Select(BitConverter.DoubleToInt64Bits));
            foreach (var flag in flags)
                Assert.Equal(expectedFlags, flag);
        }
    }
}
