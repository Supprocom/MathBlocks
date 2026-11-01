using System.Globalization;
using System.Runtime.CompilerServices;
using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the causality labels of the standard catalog.</summary>
public sealed class MathBlockCausalityTests
{
    private const string StandardCausalityFingerprint =
        "08ebbaf1d6ae091edef0fac05a0ce513b2841c2008efc0e17bdb99757b17adbe";

    /// <summary>Verifies every standard operation has an explicit causality label.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void EveryStandardOperationHasACausalityLabel()
    {
        var operations = MathBlockCatalog.Standard.Operations;
        Assert.Equal(337, operations.Count);
        Assert.All(operations, operation =>
        {
            var causality = operation.Causality;
            if (causality.Kind == MathBlockCausality.Trailing)
            {
                var widthInputIndex = Assert.NotNull(causality.WidthInputIndex);
                Assert.InRange(widthInputIndex, 0, operation.Arity - 1);
                Assert.Equal(
                    MathBlockValueKind.Scalar,
                    operation.PerformanceCase.Inputs[widthInputIndex].Type.Kind);
            }
            else
            {
                Assert.Null(causality.WidthInputIndex);
            }
        });

        var blocksRoot = Path.Combine(FindRepositoryRoot(), "Supprocom.MathBlocks", "Blocks");
        var definitions = Directory.GetFiles(blocksRoot, "*.Definition.cs", SearchOption.AllDirectories);
        Assert.Equal(operations.Count, definitions.Length);
        Assert.All(definitions, definition => Assert.Contains(
            "internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.",
            File.ReadAllText(definition),
            StringComparison.Ordinal));
    }

    /// <summary>Verifies the standard causality fingerprint is stable and follows its documented material.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void StandardCausalityFingerprintIsStable()
    {
        var lines = MathBlockCatalog.Standard.Operations
            .Select(operation => operation.Causality.WidthInputIndex is { } index
                ? string.Create(CultureInfo.InvariantCulture, $"{operation.Identity}={operation.Causality.Kind}:{index}")
                : $"{operation.Identity}={operation.Causality.Kind}")
            .Order(StringComparer.Ordinal);
        var material = string.Concat(lines.Select(line => line + "\n"));
        var expected = Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(material)));

        Assert.Equal(expected, MathBlockCatalog.Standard.CausalityFingerprint);
        Assert.Equal(StandardCausalityFingerprint, MathBlockCatalog.Standard.CausalityFingerprint);
    }

    /// <summary>Verifies an operation is NotSeries exactly when it has no vector-kind input.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void NotSeriesLabelsMatchOperationsWithoutVectorKindInputs()
    {
        Assert.All(MathBlockCatalog.Standard.Operations, operation =>
        {
            var series = operation.PerformanceCase.Inputs.Any(input => input.Type.Kind is
                MathBlockValueKind.Vector or MathBlockValueKind.BooleanVector or MathBlockValueKind.ComplexVector);
            Assert.True(
                series == (operation.Causality.Kind != MathBlockCausality.NotSeries),
                $"{operation.Identity} is {operation.Causality} with vector-kind input: {series}.");
        });
    }

    /// <summary>Verifies every Pointwise, Trailing and Expanding label against seeded random perturbations.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void CausalLabelsHoldUnderLaterAndOutOfWindowPerturbations()
    {
        var failures = CheckLabels(MathBlockCatalog.Standard, causal: true, out var checkedCount);
        Assert.True(failures.Count == 0, MathBlockCausalityChecks.Format(failures));
        Assert.True(checkedCount > 0, "No causal label was checked.");
    }

    /// <summary>Verifies every WholeSeries and Forward label reads rows after the output row.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void NonCausalLabelsChangeWhenLaterRowsChange()
    {
        var failures = CheckLabels(MathBlockCatalog.Standard, causal: false, out var checkedCount);
        Assert.True(failures.Count == 0, MathBlockCausalityChecks.Format(failures));
        Assert.True(checkedCount > 0, "No non-causal label was checked.");
    }

    /// <summary>Verifies the property check rejects whole-series and expanding operations labelled Pointwise.</summary>
    [Theory]
    [Trait("Category", "CausalityContract")]
    [InlineData("vector.standardize", "when rows after")]
    [InlineData("vector.cumulative-sum", "when rows before")]
    [InlineData("vector.reverse", "when rows after")]
    public void PropertyCheckRejectsAMislabelledOperation(string identifier, string expectedReason)
    {
        var mislabelled = Relabel(MathBlockCatalog.Standard.Get(identifier), MathBlockCausalityInfo.Pointwise);

        var failures = MathBlockCausalityChecks.Check(mislabelled);

        Assert.NotEmpty(failures);
        Assert.Contains(failures, failure => failure.Contains(expectedReason, StringComparison.Ordinal));
    }

    /// <summary>
    /// Verifies the property check rejects a broken lift of an integer-domain operation, in which row t reads row
    /// t - 1 of the first vector argument. Over real-valued rows these forms return the fill value on every row (and
    /// their validity siblings return false on every row), so the check has to choose integer rows to see the shift.
    /// </summary>
    [Theory]
    [Trait("Category", "CausalityContract")]
    [InlineData("combinatorics.ballot-count")]
    [InlineData("combinatorics.binomial-coefficient")]
    [InlineData("combinatorics.factorial")]
    [InlineData("probability.poisson-cdf")]
    public void PropertyCheckRejectsABrokenLiftOfAnIntegerDomainOperation(string source)
    {
        foreach (var form in new[] { MathBlockElementwiseTestSupport.Form(source), MathBlockElementwiseTestSupport.Validity(source) })
        {
            Assert.Empty(MathBlockCausalityChecks.Check(form));

            var failures = MathBlockCausalityChecks.Check(ShiftFirstVectorArgument(form));

            Assert.True(failures.Count != 0, $"The check accepted a shifted {form.Identity}.");
        }
    }

    /// <summary>Verifies the reverse check rejects a causal operation labelled WholeSeries.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void ReverseCheckRejectsACausalOperationLabelledWholeSeries()
    {
        var mislabelled = Relabel(MathBlockCatalog.Standard.Get("vector.add"), MathBlockCausalityInfo.WholeSeries);

        Assert.NotEmpty(MathBlockCausalityChecks.Check(mislabelled));
    }

    /// <summary>Verifies a program reports the weakest kind over its series operations.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void ProgramCausalityIsTheWeakestSeriesKind()
    {
        var registry = MathBlockCatalog.Standard;
        var builder = new MathBlockProgramBuilder(registry);
        var values = builder.Input("values", MathBlockType.Vector());
        var scale = builder.Input("scale", MathBlockType.Scalar());
        var doubled = builder.Apply("scalar.multiply", 1, scale, builder.Constant(MathBlockValue.Scalar(2d)));
        var scaled = builder.Apply("vector.scale", 1, values, doubled);
        Assert.Equal(MathBlockCausality.Pointwise, builder.Output("scaled", scaled).Build().Causality);

        var width = builder.Constant(MathBlockValue.Scalar(2d));
        var rolling = builder.Apply("sequence.rolling-maximum", 1, scaled, width);
        Assert.Equal(MathBlockCausality.Trailing, builder.Output("rolling", rolling).Build().Causality);

        var cumulative = builder.Apply("vector.cumulative-sum", 1, rolling);
        Assert.Equal(MathBlockCausality.Expanding, builder.Output("cumulative", cumulative).Build().Causality);

        var standardized = builder.Apply("vector.standardize", 1, cumulative);
        Assert.Equal(MathBlockCausality.WholeSeries, builder.Output("standardized", standardized).Build().Causality);

        var reversed = builder.Apply("vector.reverse", 1, values);
        Assert.Equal(MathBlockCausality.Forward, builder.Output("reversed", reversed).Build().Causality);

        var scalarBuilder = new MathBlockProgramBuilder(registry);
        var left = scalarBuilder.Input("left", MathBlockType.Scalar());
        var sum = scalarBuilder.Apply("scalar.add", 1, left, scalarBuilder.Constant(MathBlockValue.Scalar(1d)));
        Assert.Equal(MathBlockCausality.NotSeries, scalarBuilder.Output("sum", sum).Build().Causality);

        var passThrough = new MathBlockProgramBuilder(registry);
        Assert.Equal(
            MathBlockCausality.NotSeries,
            passThrough.Output("values", passThrough.Input("values", MathBlockType.Vector())).Build().Causality);
    }

    /// <summary>Verifies operations built without a label have no causality and labels are validated.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void UnlabelledOperationsAndInvalidLabelsAreRejected()
    {
        var source = MathBlockCatalog.Standard.Get("vector.add");
        var unlabelled = new MathBlockOperation(
            source.Identifier,
            source.Version,
            source.Arity,
            source.ResolveOutputType,
            inputs => source.Evaluate(inputs),
            source.RegressionCases,
            source.PerformanceCase);
        Assert.Throws<InvalidOperationException>(() => unlabelled.Causality);
        Assert.Throws<InvalidOperationException>(() => new MathBlockRegistry([unlabelled]).CausalityFingerprint);
        var builder = new MathBlockProgramBuilder(new MathBlockRegistry([unlabelled]));
        var values = builder.Input("values", MathBlockType.Vector());
        var program = builder.Output("sum", builder.Apply("vector.add", 1, values, values)).Build();
        Assert.Throws<InvalidOperationException>(() => program.Causality);

        Assert.Throws<ArgumentException>(() => Relabel(source, MathBlockCausalityInfo.Trailing(2)));
        Assert.Throws<ArgumentNullException>(() => Relabel(source, null!));
        Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockCausalityInfo.Trailing(-1));
    }

    /// <summary>Verifies warm-up rows and the label text.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void WarmUpRowsAndLabelTextFollowTheKind()
    {
        var trailing = MathBlockCausalityInfo.Trailing(1);
        Assert.Equal(MathBlockCausality.Trailing, trailing.Kind);
        Assert.Equal(1, trailing.WidthInputIndex);
        Assert.Equal(0, trailing.WarmUpRows(1));
        Assert.Equal(4, trailing.WarmUpRows(5));
        Assert.Equal("Trailing:1", trailing.ToString());
        Assert.Equal(0, MathBlockCausalityInfo.Expanding.WarmUpRows(5));
        Assert.Equal("Expanding", MathBlockCausalityInfo.Expanding.ToString());
        Assert.Throws<ArgumentOutOfRangeException>(() => trailing.WarmUpRows(0));

        var rolling = MathBlockCatalog.Standard.Get("sequence.rolling-maximum");
        var output = rolling.Evaluate(MathBlockValue.Vector([5d, 1d, 4d, 2d, 3d]), MathBlockValue.Scalar(3d));
        Assert.Equal(5 - rolling.Causality.WarmUpRows(3), output.AsVector().Count);
        Assert.Equal(new[] { 5d, 4d, 4d }, output.AsVector().ToArray());
    }

    internal static List<string> CheckLabels(MathBlockRegistry registry, bool causal, out int checkedCount)
    {
        var failures = new List<string>();
        checkedCount = 0;
        foreach (var operation in registry.Operations)
        {
            var kind = operation.Causality.Kind;
            if (kind == MathBlockCausality.NotSeries ||
                causal != (kind is MathBlockCausality.Pointwise or MathBlockCausality.Trailing or MathBlockCausality.Expanding))
            {
                continue;
            }
            checkedCount++;
            failures.AddRange(MathBlockCausalityChecks.Check(operation));
        }
        return failures;
    }

    internal static MathBlockOperation Relabel(MathBlockOperation source, MathBlockCausalityInfo causality) =>
        new(
            source.Identifier,
            source.Version,
            source.Arity,
            source.ResolveOutputType,
            inputs => source.Evaluate(inputs),
            source.RegressionCases,
            source.PerformanceCase,
            causality);

    // Row t of the result reads row t - 1 (row 0 for t = 0) of the first vector argument, still labelled Pointwise.
    private static MathBlockOperation ShiftFirstVectorArgument(MathBlockOperation source) =>
        new(
            source.Identifier,
            source.Version,
            source.Arity,
            source.ResolveOutputType,
            inputs =>
            {
                var shifted = inputs.ToArray();
                var index = Array.FindIndex(shifted, input => input.IsValid && input.Type.Kind == MathBlockValueKind.Vector);
                if (index >= 0)
                {
                    var values = shifted[index].AsVector();
                    shifted[index] = MathBlockValue.Vector(
                        Enumerable.Range(0, values.Count).Select(row => values[Math.Max(0, row - 1)]),
                        shifted[index].Type.Unit);
                }
                return source.Evaluate(shifted);
            },
            source.RegressionCases,
            source.PerformanceCase,
            MathBlockCausalityInfo.Pointwise);

    private static string FindRepositoryRoot([CallerFilePath] string sourceFile = "")
    {
        foreach (var start in new[] { Path.GetDirectoryName(sourceFile)!, Directory.GetCurrentDirectory(), AppContext.BaseDirectory })
        {
            var directory = new DirectoryInfo(start);
            while (directory is not null)
            {
                if (Directory.Exists(Path.Combine(directory.FullName, "Supprocom.MathBlocks", "Blocks")))
                    return directory.FullName;
                directory = directory.Parent;
            }
        }
        throw new DirectoryNotFoundException("The repository root was not found.");
    }
}
