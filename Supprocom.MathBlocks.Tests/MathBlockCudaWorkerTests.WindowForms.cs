using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

// CoreCLR/CUDA parity of the window forms and siblings: value bits, type, shape and invalid state of the CUDA
// output equal the CoreCLR lift on the same inputs.
public sealed partial class MathBlockCudaWorkerTests
{
    private const int WindowFullLength = 302_893;
    private const double WindowSentinel = -98_765.25d;

    /// <summary>Gets every source identifier of the window forms.</summary>
    public static TheoryData<string> WindowSources => [.. SourceIdentifiers];

    /// <summary>
    /// Verifies every form and sibling on the regression sample, seeded 300-row series at widths 1, 2, 17, 96 and
    /// 300, a fill equal to a computed value, run-time widths above n and non-integer, and unequal series lengths.
    /// </summary>
    [Fact]
    [Trait("Category", "WindowCuda")]
    public void CUDAWindowFormsMatchTheCoreCLRLiftOnSamplesAndEdgeCases()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        var caseCount = 0;
        var invalidCount = 0;
        foreach (var source in SourceIdentifiers)
        {
            foreach (var windowCase in CreateWindowCases(source))
            {
                caseCount++;
                var coreclr = windowCase.Operation.Evaluate(windowCase.Inputs);
                if (!coreclr.IsValid)
                    invalidCount++;
                var cuda = ExecuteWindowCase(worker, windowCase.Operation, windowCase.Prototype, windowCase.Inputs);
                if (DescribeWindowDifference(coreclr, cuda) is { } difference)
                    failures.Add($"{windowCase.Operation.Identity}/{windowCase.Name}: {difference}");
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(60)));
        Assert.True(caseCount >= 53 * 17, $"Only {caseCount} window cases ran.");
        // At least the run-time width above n and the non-integer width make each form and sibling invalid.
        Assert.True(invalidCount >= 53 * 4, $"Only {invalidCount} window cases were invalid.");
    }

    /// <summary>
    /// Verifies the order-statistic windows keep the zero bit the source's stable sort selects: Theil-Sen slopes
    /// and pseudomedian averages of signed zeros, and medians and quantiles of windows mixing -0.0 and +0.0.
    /// </summary>
    [Fact]
    [Trait("Category", "WindowCuda")]
    public void CUDAWindowOrderStatisticsPreserveSignedZeroBits()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        foreach (var (source, width) in new[]
                 {
                     ("statistics.theil-sen-slope", 7), ("statistics.pseudomedian", 6), ("vector.median", 7),
                     ("vector.quantile", 5), ("statistics.interquartile-range", 9),
                     ("statistics.median-absolute-deviation", 7)
                 })
        {
            var random = new Random(97 + width);
            var series = CreateSignedZeroSeries(source, 160, random);
            var unit = Form(source).ResolveOutputType(
                [.. series.Select(input => input.Type), MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
            var inputs = FormInputs(series, width, MathBlockValue.Scalar(WindowSentinel, unit));
            var coreclr = Form(source).Evaluate(inputs);
            var cuda = ExecuteWindowCase(worker, Form(source), inputs, inputs);
            if (DescribeWindowDifference(coreclr, cuda) is { } difference)
                failures.Add($"{source}: {difference}");
            if (string.Equals(source, "statistics.median-absolute-deviation", StringComparison.Ordinal) ||
                string.Equals(source, "statistics.interquartile-range", StringComparison.Ordinal) ||
                !coreclr.IsValid)
                continue;
            var negativeZeros = coreclr.AsVector().Count(value => BitConverter.DoubleToInt64Bits(value) == long.MinValue);
            var positiveZeros = coreclr.AsVector().Count(value => BitConverter.DoubleToInt64Bits(value) == 0L);
            if (negativeZeros == 0 || positiveZeros == 0)
                failures.Add($"{source}: the data gave {negativeZeros} rows of -0.0 and {positiveZeros} of +0.0.");
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>
    /// Verifies the form and sibling at the full PatternResearcher length of 302,893 rows and widths 2, 17 and 96
    /// against the CoreCLR lift, row for row.
    /// </summary>
    [Theory]
    [MemberData(nameof(WindowSources))]
    [Trait("Category", "WindowCudaFullScale")]
    public void CUDAWindowFormsMatchTheCoreCLRLiftAtFullLength(string source)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        var computedWidths = 0;
        foreach (var width in new[] { 2, 17, 96 })
        {
            var series = CreateSourceInputs(source, WindowFullLength, width, 31_000 + width);
            var unit = Form(source).ResolveOutputType(
                [.. series.Select(input => input.Type), MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
            var formInputs = FormInputs(series, width, MathBlockValue.Scalar(WindowSentinel, unit));
            var validityInputs = ValidityInputs(series, width);
            MathBlockValue coreclrForm = default;
            MathBlockValue coreclrValidity = default;
            Parallel.Invoke(
                () => coreclrForm = Form(source).Evaluate(formInputs),
                () => coreclrValidity = Validity(source).Evaluate(validityInputs));
            var cudaForm = ExecuteWindowCase(worker, Form(source), formInputs, formInputs);
            var cudaValidity = ExecuteWindowCase(worker, Validity(source), validityInputs, validityInputs);
            if (DescribeWindowDifference(coreclrForm, cudaForm) is { } formDifference)
                failures.Add($"window.{source} w={width}: {formDifference}");
            if (DescribeWindowDifference(coreclrValidity, cudaValidity) is { } validityDifference)
                failures.Add($"window-valid.{source} w={width}: {validityDifference}");
            if (coreclrValidity.IsValid && coreclrValidity.AsBooleanVector().Any(value => value))
                computedWidths++;
        }

        // Some sources fill every row at width 2 (autocorrelation at lag 1 has one pair per window), so the
        // check that the data computes rows covers the three widths together.
        if (computedWidths == 0)
            failures.Add($"{source}: the CoreCLR lift computed no row at any width.");
        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    private static IEnumerable<WindowCase> CreateWindowCases(string source)
    {
        var form = Form(source);
        var validity = Validity(source);
        yield return new WindowCase("regression", form, form.RegressionCases[0].Inputs.ToArray(), form.RegressionCases[0].Inputs.ToArray());
        yield return new WindowCase("regression", validity, validity.RegressionCases[0].Inputs.ToArray(), validity.RegressionCases[0].Inputs.ToArray());
        const int count = 300;
        foreach (var width in new[] { 1, 2, 17, 96, count })
        {
            var series = CreateSourceInputs(source, count, width, 7_000 + width);
            var formInputs = FormInputs(series, width, MathBlockValue.Scalar(WindowSentinel, FillUnit(source, series)));
            var validityInputs = ValidityInputs(series, width);
            yield return new WindowCase($"n={count} w={width}", form, formInputs, formInputs);
            yield return new WindowCase($"n={count} w={width}", validity, validityInputs, validityInputs);
        }

        var seeded = CreateSourceInputs(source, count, 17, 7_017);
        var computed = form.Evaluate(FormInputs(seeded, 17, MathBlockValue.Scalar(WindowSentinel, FillUnit(source, seeded))));
        var realValue = computed.IsValid
            ? computed.AsVector().Skip(16).FirstOrDefault(value => value != WindowSentinel, 0.25d)
            : 0.25d;
        var realFill = FormInputs(seeded, 17, MathBlockValue.Scalar(realValue, FillUnit(source, seeded)));
        yield return new WindowCase("fill equal to a computed value", form, realFill, realFill);

        var planned = CreateSourceInputs(source, count, 2, 7_002);
        var plannedForm = FormInputs(planned, 2, MathBlockValue.Scalar(WindowSentinel, FillUnit(source, planned)));
        var plannedValidity = ValidityInputs(planned, 2);
        foreach (var runtimeWidth in new[] { count + 1d, 2.5d })
        {
            var formInputs = (MathBlockValue[])plannedForm.Clone();
            formInputs[^2] = MathBlockValue.Scalar(runtimeWidth);
            var validityInputs = (MathBlockValue[])plannedValidity.Clone();
            validityInputs[^1] = MathBlockValue.Scalar(runtimeWidth);
            yield return new WindowCase($"run-time width {runtimeWidth}", form, plannedForm, formInputs);
            yield return new WindowCase($"run-time width {runtimeWidth}", validity, plannedValidity, validityInputs);
        }

        if (seeded.Take(3).Count(input => input.Type.Kind == MathBlockValueKind.Vector) == 2)
        {
            var unequal = (MathBlockValue[])seeded.Clone();
            unequal[1] = MathBlockValue.Vector(unequal[1].AsVector().ToArray()[..(count - 1)], unequal[1].Type.Unit);
            var formInputs = FormInputs(unequal, 17, MathBlockValue.Scalar(WindowSentinel, FillUnit(source, unequal)));
            var validityInputs = ValidityInputs(unequal, 17);
            yield return new WindowCase("unequal lengths", form, formInputs, formInputs);
            yield return new WindowCase("unequal lengths", validity, validityInputs, validityInputs);
        }
    }

    // Series whose windows mix -0.0 and +0.0: Theil-Sen gets distinct x and signed-zero y, so every slope is a
    // signed zero; the other sources get values from {-0.0, +0.0, -1, 1}, mostly zeros.
    private static MathBlockValue[] CreateSignedZeroSeries(string source, int count, Random random)
    {
        double SignedZero() => random.Next(2) == 0 ? -0d : 0d;
        if (string.Equals(source, "statistics.theil-sen-slope", StringComparison.Ordinal))
        {
            var x = new double[count];
            var y = new double[count];
            for (var row = 0; row < count; row++)
            {
                x[row] = row + random.NextDouble() * 0.5d;
                y[row] = SignedZero();
            }
            return [MathBlockValue.Vector(x), MathBlockValue.Vector(y)];
        }
        var values = new double[count];
        for (var row = 0; row < count; row++)
            values[row] = random.Next(5) switch { 0 => -1d, 1 => 1d, _ => SignedZero() };
        if (string.Equals(source, "vector.quantile", StringComparison.Ordinal))
            return [MathBlockValue.Vector(values), MathBlockValue.Scalar(0.25d)];
        if (string.Equals(source, "statistics.pseudomedian", StringComparison.Ordinal))
        {
            for (var row = 0; row < count; row++)
                values[row] = SignedZero();
        }
        return [MathBlockValue.Vector(values)];
    }

    private static MathBlockUnit FillUnit(string source, MathBlockValue[] series) =>
        Form(source).ResolveOutputType(
            [.. series.Select(input => input.Type), MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;

    // Compiles the operation with the prototype inputs (which set the static width and scratch plan) and runs it
    // on the inputs.
    private static MathBlockValue ExecuteWindowCase(
        MathBlocksCUDAWorker worker,
        MathBlockOperation operation,
        MathBlockValue[] prototype,
        MathBlockValue[] inputs)
    {
        var builder = new MathBlockProgramBuilder(Windowed);
        var nodes = prototype.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
        using var compiled = worker.Compile(program, NameWindowInputs(prototype));
        return compiled.Execute(NameWindowInputs(inputs))["result"];
    }

    private static Dictionary<string, MathBlockValue> NameWindowInputs(MathBlockValue[] inputs) =>
        inputs.Select((input, index) => new KeyValuePair<string, MathBlockValue>($"input-{index}", input))
            .ToDictionary(item => item.Key, item => item.Value, StringComparer.Ordinal);

    private static string? DescribeWindowDifference(MathBlockValue expected, MathBlockValue actual)
    {
        if (expected.Type != actual.Type)
            return $"type {actual.Type}, expected {expected.Type}";
        if (expected.IsValid != actual.IsValid)
            return $"valid {actual.IsValid}, expected {expected.IsValid} ({expected.InvalidReason ?? actual.InvalidReason})";
        if (!expected.IsValid)
            return null;
        if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
        {
            var expectedFlags = expected.AsBooleanVector();
            var actualFlags = actual.AsBooleanVector();
            if (expectedFlags.Count != actualFlags.Count)
                return $"length {actualFlags.Count}, expected {expectedFlags.Count}";
            for (var row = 0; row < expectedFlags.Count; row++)
                if (expectedFlags[row] != actualFlags[row])
                    return $"row {row}: {actualFlags[row]}, expected {expectedFlags[row]}";
            return null;
        }
        var expectedValues = expected.AsVector();
        var actualValues = actual.AsVector();
        if (expectedValues.Count != actualValues.Count)
            return $"length {actualValues.Count}, expected {expectedValues.Count}";
        var mismatches = 0;
        var first = -1;
        for (var row = 0; row < expectedValues.Count; row++)
        {
            if (BitConverter.DoubleToInt64Bits(expectedValues[row]) == BitConverter.DoubleToInt64Bits(actualValues[row]))
                continue;
            mismatches++;
            if (first < 0)
                first = row;
        }
        return mismatches == 0
            ? null
            : $"{mismatches} rows differ; first row {first}: {actualValues[first]:R}, expected {expectedValues[first]:R}";
    }

    private sealed record WindowCase(
        string Name,
        MathBlockOperation Operation,
        MathBlockValue[] Prototype,
        MathBlockValue[] Inputs);
}
