using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockWindowM2TestSupport;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

// CoreCLR/CUDA parity of the window-accurate forms and siblings, and of the median and quantile forms whose CUDA
// threads slide a sorted window over a block of rows: value bits, type, shape and invalid state of the CUDA output
// equal the CoreCLR result on the same inputs.
public sealed partial class MathBlockCudaWorkerTests
{
    /// <summary>Gets the input families of the window-accurate parity tests.</summary>
    public static TheoryData<string> WindowAccurateFamilies =>
        ["random", "offset-1e9", "near-constant", "alternating", "random-walk", "spike", "equal-runs", "out-of-range"];

    /// <summary>
    /// Verifies the twelve window-accurate operations, and the median and quantile forms and siblings, on the
    /// regression samples, every family at 700 rows and widths 1, 2, 3, 17, 96 and 700, overflowing, tiny, huge,
    /// subnormal, signed-zero and constant windows, a fill equal to a computed value, and run-time widths above n,
    /// non-integer and different from the planned width.
    /// </summary>
    [Fact]
    [Trait("Category", "WindowCuda")]
    public void CUDAWindowAccurateFormsMatchCoreCLROnSamplesAndEdgeCases()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        var cases = CreateAccurateCases().ToArray();
        var caseCount = 0;
        var computedFamilies = new HashSet<string>(StringComparer.Ordinal);
        foreach (var windowCase in cases)
        {
            caseCount++;
            var coreclr = windowCase.Operation.Evaluate(windowCase.Inputs);
            if (coreclr.IsValid && coreclr.Type.Kind == MathBlockValueKind.BooleanVector &&
                coreclr.AsBooleanVector().Any(value => value))
                computedFamilies.Add(windowCase.Name.Split(' ')[0]);
            var cuda = ExecuteWindowCase(worker, windowCase.Operation, windowCase.Prototype, windowCase.Inputs);
            if (DescribeWindowDifference(coreclr, cuda) is { } difference)
                failures.Add($"{windowCase.Operation.Identity}/{windowCase.Name}: {difference}");
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(60)));
        // Every generated case ran, and every family computed sibling rows on CoreCLR, so the parity above covered
        // computed rows of each family and not only filled ones.
        Assert.Equal(cases.Length, caseCount);
        var uncomputed = WindowAccurateFamilies.Cast<object[]>().Select(row => (string)row[0]).Where(family => !computedFamilies.Contains(family)).ToArray();
        Assert.True(uncomputed.Length == 0, $"No sibling row was computed for: {string.Join(", ", uncomputed)}");
    }

    /// <summary>
    /// Verifies the twelve window-accurate operations, and the median and quantile forms and siblings, at the full
    /// PatternResearcher length of 302,893 rows and widths 2, 17 and 96 on one input family, row for row.
    /// </summary>
    [Theory]
    [MemberData(nameof(WindowAccurateFamilies))]
    [Trait("Category", "WindowCudaFullScale")]
    public void CUDAWindowAccurateFormsMatchCoreCLRAtFullLength(string family)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        var values = CreateAccurateFamily(family, WindowFullLength, 41);
        var computed = 0;
        foreach (var width in new[] { 2, 17, 96 })
        {
            foreach (var windowCase in AccurateSeriesCases($"w={width}", values, width))
            {
                var coreclr = windowCase.Operation.Evaluate(windowCase.Inputs);
                var cuda = ExecuteWindowCase(worker, windowCase.Operation, windowCase.Inputs, windowCase.Inputs);
                if (DescribeWindowDifference(coreclr, cuda) is { } difference)
                    failures.Add($"{windowCase.Operation.Identity} {windowCase.Name}: {difference}");
                if (coreclr.IsValid && coreclr.Type.Kind == MathBlockValueKind.BooleanVector &&
                    coreclr.AsBooleanVector().Any(value => value))
                    computed++;
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(60)));
        // The parity above covered computed rows, not only filled ones.
        Assert.True(computed > 0, $"{family}: no sibling computed a row.");
    }

    /// <summary>
    /// Verifies the CUDA window batch: each width's result (widths 1, 2, 3, 17, 96 and 400) is bit-identical to the
    /// form evaluated alone on CUDA and on CoreCLR, and the paired entry point equals the form and its sibling
    /// evaluated alone, for every form the batch supports.
    /// </summary>
    [Fact]
    [Trait("Category", "WindowCuda")]
    public void CUDAWindowBatchEqualsEachFormEvaluatedAlone()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        int[] widths = [1, 2, 3, 17, 96, 400];
        var random = new Random(47);
        var values = new double[400];
        for (var row = 0; row < values.Length; row++)
            values[row] = row is >= 100 and < 220 ? 7d : random.Next(5) == 0 ? -0d : random.NextDouble() * 50d;
        var series = MathBlockValue.Vector(values);
        var checkedResults = 0;
        var expectedResults = 0;
        foreach (var identity in MathBlocksWindowBatchTests.Identities.Cast<object[]>().Select(row => (string)row[0]))
        {
            var operation = MathBlocksWindowBatchTests.Resolve(identity);
            var sibling = Windowed.Get(MathBlocksWindowBatchTests.SiblingIdentifier(identity));
            foreach (var parameters in MathBlocksWindowBatchTests.Parameters(identity))
            {
                expectedResults += widths.Length;
                var batch = parameters.Length == 0
                    ? MathBlocksWindowBatch.EvaluateCUDA(worker, series, identity, widths, WindowSentinel)
                    : MathBlocksWindowBatch.EvaluateCUDA(worker, series, identity, parameters, widths, WindowSentinel);
                for (var index = 0; index < widths.Length; index++)
                {
                    MathBlockValue[] inputs = [series, .. parameters, MathBlockValue.Scalar(widths[index]), MathBlockValue.Scalar(WindowSentinel)];
                    var coreclr = operation.Evaluate(inputs);
                    var alone = ExecuteWindowCase(worker, operation, inputs, inputs);
                    if (DescribeWindowDifference(coreclr, batch[index]) is { } coreclrDifference)
                        failures.Add($"{identity} w={widths[index]} batch against CoreCLR: {coreclrDifference}");
                    if (DescribeWindowDifference(alone, batch[index]) is { } cudaDifference)
                        failures.Add($"{identity} w={widths[index]} batch against CUDA alone: {cudaDifference}");
                    checkedResults++;
                }
                MathBlockValue[] paired = [series, .. parameters, MathBlockValue.Scalar(17d), MathBlockValue.Scalar(WindowSentinel)];
                var result = MathBlocksWindowBatch.EvaluateWithValidityCUDA(worker, identity, paired);
                if (DescribeWindowDifference(operation.Evaluate(paired), result.Values) is { } valuesDifference)
                    failures.Add($"{identity} paired values: {valuesDifference}");
                if (DescribeWindowDifference(sibling.Evaluate(paired[..^1]), result.Validity) is { } validityDifference)
                    failures.Add($"{identity} paired validity: {validityDifference}");
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(60)));
        // One result per width for every supported form and parameter set the batch tests define: 12 forms, the
        // quantile with three probabilities.
        Assert.Equal(expectedResults, checkedResults);
        Assert.Equal((MathBlocksWindowBatchTests.Identities.Cast<object[]>().Count() + 2) * widths.Length, checkedResults);
    }

    // The families of MathBlockWindowAccurateTests, runs of 60 equal full-significand values (and of signed zeros)
    // between varied rows, and segments outside the double-double range (tiny, large, huge, overflowing values
    // between normal ones).
    private static double[] CreateAccurateFamily(string family, int count, int seed)
    {
        if (family is not ("equal-runs" or "out-of-range"))
            return MathBlockWindowAccurateTests.CreateFamily(family, count, seed);
        var random = new Random(seed);
        var values = new double[count];
        var constant = 0d;
        for (var row = 0; row < count; row++)
        {
            if (row % 80 == 0)
                constant = (random.NextDouble() * 2d - 1d) * Math.Pow(10d, random.Next(-50, 51));
            values[row] = string.Equals(family, "equal-runs", StringComparison.Ordinal)
                ? row % 80 < 60 ? constant : row % 160 < 80 ? -0d : 1_000d + random.NextDouble() * 3d
                : (row / 300 % 6) switch
                {
                    0 => 1e-160d * (1d + random.NextDouble()),
                    1 => 1e150d * (1d + 0.1d * random.NextDouble()),
                    2 => 5e153d * (1d + 0.02d * random.NextDouble()),
                    3 => random.Next(5) == 0 ? 0d : random.NextDouble() * 2d - 1d,
                    4 => random.Next(2) == 0 ? 1e-100d * (1d + random.NextDouble()) : 1e149d * (1d + random.NextDouble()),
                    _ => random.Next(3) == 0 ? 1e308d : -1e308d
                };
        }
        return values;
    }

    // Max(4w, 1024) rows of -0.0 and +0.0 (seven in eight rows), with 1 and -1 as the remaining rows.
    private static double[] CreateMixedZeroSeries(int width)
    {
        var random = new Random(4100 + width);
        var values = new double[Math.Max(4 * width, 8 * 128)];
        for (var row = 0; row < values.Length; row++)
            values[row] = random.Next(16) switch { 0 => 1d, 1 => -1d, var pick => pick % 2 == 0 ? -0d : 0d };
        return values;
    }

    // Each window-accurate form and sibling, the median form and sibling, and the quantile form and sibling at
    // probabilities 0, 0.25, 0.9 and 1, on one series and width.
    private static IEnumerable<WindowCase> AccurateSeriesCases(string name, double[] values, int width)
    {
        var x = MathBlockValue.Vector(values);
        var w = MathBlockValue.Scalar(width);
        foreach (var accurate in AccurateNames)
        {
            var form = AccurateForm(accurate);
            var unit = form.ResolveOutputType([x.Type, MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
            MathBlockValue[] formInputs = [x, w, MathBlockValue.Scalar(WindowSentinel, unit)];
            MathBlockValue[] validityInputs = [x, w];
            yield return new WindowCase(name, form, formInputs, formInputs);
            yield return new WindowCase(name, AccurateValidity(accurate), validityInputs, validityInputs);
        }
        MathBlockValue[] median = [x, w, MathBlockValue.Scalar(WindowSentinel)];
        MathBlockValue[] medianValidity = [x, w];
        yield return new WindowCase(name, Form("vector.median"), median, median);
        yield return new WindowCase(name, Validity("vector.median"), medianValidity, medianValidity);
        foreach (var probability in new[] { 0d, 0.25d, 0.9d, 1d })
        {
            var p = MathBlockValue.Scalar(probability);
            MathBlockValue[] quantile = [x, p, w, MathBlockValue.Scalar(WindowSentinel)];
            MathBlockValue[] quantileValidity = [x, p, w];
            yield return new WindowCase($"{name} p={probability}", Form("vector.quantile"), quantile, quantile);
            yield return new WindowCase($"{name} p={probability}", Validity("vector.quantile"), quantileValidity, quantileValidity);
        }
    }

    private static IEnumerable<WindowCase> CreateAccurateCases()
    {
        foreach (var accurate in AccurateNames)
        {
            foreach (var operation in new[] { AccurateForm(accurate), AccurateValidity(accurate) })
            {
                var inputs = operation.RegressionCases[0].Inputs.ToArray();
                yield return new WindowCase("regression", operation, inputs, inputs);
            }
        }

        const int count = 700;
        foreach (var family in WindowAccurateFamilies)
        {
            var values = CreateAccurateFamily(family, count, 23);
            foreach (var width in new[] { 1, 2, 3, 17, 96, count })
                foreach (var item in AccurateSeriesCases($"{family} w={width}", values, width))
                    yield return item;
        }

        var edges = new (string Name, double[] Values, int[] Widths)[]
        {
            ("overflow", [1e308d, 1e308d, -1e308d, 2d, 3d], [1, 2, 3]),
            ("tiny", [1e-160d, 2e-160d, 3e-160d, 4e-160d], [1, 2]),
            ("huge", [5e153d, 5.1e153d, 5e153d, 5.1e153d], [2, 3]),
            ("large", [1e150d, 1.1e150d, 1e150d, 1.1e150d], [2]),
            ("inside", [1e-100d, 2e-100d, 1e149d, 1.1e149d], [2]),
            ("subnormal", [5e-324d, -5e-324d, 1e-310d, 2.5e-308d, -1e-320d, 0d, double.Epsilon, 3e-320d, -2.2e-308d, 7e-315d], [1, 2, 3, 10]),
            ("square underflow", [5e-324d, -5e-324d, 1e-140d, -1e-140d, 1e-170d, 0d, 0d, -0d], [2, 3]),
            ("constant", [.. Enumerable.Repeat(-1.0101787042252373e+32d, 20), 1d, 2d], [2, 7, 20]),
            ("extremes", [double.MaxValue, double.Epsilon, -double.MaxValue, 1d, -double.Epsilon, 1e-300d, 1e300d], [1, 2, 3, 7])
        };
        foreach (var (name, values, widths) in edges)
            foreach (var width in widths)
                foreach (var item in AccurateSeriesCases($"{name} w={width}", values, width))
                    yield return item;

        // Windows that mix -0.0 and +0.0 with a few ones. A thread removes a value only from its second row on, and a
        // launch of up to 128 rows gives every thread one row; so each series has at least 4w rows and at least eight
        // rows for each of the 128 threads of a one-block launch. A removal then has to pick the leaving zero's own
        // bit pattern among equal values, which the 8-row series of the first version never exercised.
        foreach (var width in new[] { 1, 2, 3, 8, 17 })
            foreach (var item in AccurateSeriesCases($"signed zeros w={width}", CreateMixedZeroSeries(width), width))
                yield return item;

        // A fill equal to a computed value; run-time widths above n, non-integer, and wider or narrower than the
        // planned width (the accumulator scratch does not depend on the width).
        var series = MathBlockValue.Vector(CreateAccurateFamily("random-walk", 300, 5));
        foreach (var accurate in AccurateNames)
        {
            var form = AccurateForm(accurate);
            var validity = AccurateValidity(accurate);
            var unit = form.ResolveOutputType([series.Type, MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
            var computed = form.Evaluate(series, MathBlockValue.Scalar(17d), MathBlockValue.Scalar(WindowSentinel, unit)).AsVector()[20];
            MathBlockValue[] realFill = [series, MathBlockValue.Scalar(17d), MathBlockValue.Scalar(computed, unit)];
            yield return new WindowCase("fill equal to a computed value", form, realFill, realFill);
            MathBlockValue[] plannedForm = [series, MathBlockValue.Scalar(17d), MathBlockValue.Scalar(WindowSentinel, unit)];
            MathBlockValue[] plannedValidity = [series, MathBlockValue.Scalar(17d)];
            foreach (var runtimeWidth in new[] { 301d, 2.5d, 2d, 96d, 300d })
            {
                var formInputs = (MathBlockValue[])plannedForm.Clone();
                formInputs[1] = MathBlockValue.Scalar(runtimeWidth);
                var validityInputs = (MathBlockValue[])plannedValidity.Clone();
                validityInputs[1] = MathBlockValue.Scalar(runtimeWidth);
                yield return new WindowCase($"run-time width {runtimeWidth}", form, plannedForm, formInputs);
                yield return new WindowCase($"run-time width {runtimeWidth}", validity, plannedValidity, validityInputs);
            }
        }
    }
}
