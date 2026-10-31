using System.Reflection;

namespace Supprocom.MathBlocks.Tests;

// The window forms are CoreCLR-only on this branch and stay out of MathBlockCatalog.Standard, so the tests reach
// their internal registry by reflection, as other tests reach internal CUDA entry points.
internal static class MathBlockWindowTestSupport
{
    private static readonly Lazy<MathBlockRegistry> windowed = new(() => (MathBlockRegistry)typeof(MathBlockCatalog)
        .GetProperty("Windowed", BindingFlags.NonPublic | BindingFlags.Static)!
        .GetValue(null)!);

    // The 53 sources of design section 2 (D5), in design order.
    public static readonly string[] SourceIdentifiers =
    [
        "statistics.autocorrelation", "statistics.central-moment", "statistics.distance-correlation",
        "statistics.interquartile-range", "statistics.kendall-tau-b", "statistics.linear-intercept",
        "statistics.linear-r-squared", "statistics.linear-slope", "statistics.median-absolute-deviation",
        "statistics.pearson-correlation", "statistics.population-covariance",
        "statistics.population-excess-kurtosis", "statistics.population-skewness",
        "statistics.population-standard-deviation", "statistics.population-variance", "statistics.pseudomedian",
        "statistics.raw-moment", "statistics.root-mean-square", "statistics.sample-covariance",
        "statistics.sample-standard-deviation", "statistics.sample-variance", "statistics.spearman-correlation",
        "statistics.theil-sen-slope", "statistics.weighted-mean", "statistics.weighted-population-variance",
        "path.longest-true-run", "path.maximum-decline", "path.maximum-relative-decline", "path.power-variation",
        "path.quadratic-variation", "path.recurrence-rate", "path.total-variation", "path.turning-point-count",
        "path.zero-crossing-count", "path.first-passage-index",
        "information.shannon-entropy", "information.renyi-entropy", "information.tsallis-entropy",
        "information.gini-impurity", "information.binary-shannon-entropy",
        "vector.sum", "vector.mean", "vector.minimum", "vector.maximum", "vector.geometric-mean",
        "vector.l1-norm", "vector.l2-norm", "vector.median", "vector.quantile",
        "vector.arg-maximum", "vector.arg-minimum",
        "vector.rank", "vector.standardize"
    ];

    public static MathBlockRegistry Windowed => windowed.Value;

    public static MathBlockOperation Form(string source) => Windowed.Get($"window.{source}");

    public static MathBlockOperation Validity(string source) => Windowed.Get($"window-valid.{source}");

    public static int SourceArity(string source) => MathBlockCatalog.Standard.Get(source).Arity;

    // Builds seeded source inputs of length count whose windows of the given width cover both computed rows and
    // source-invalid rows: a constant run (flat windows), ties, zeros, and probability rows that only sum to one
    // on aligned windows. Parameters come from the form's regression sample.
    public static MathBlockValue[] CreateSourceInputs(string source, int count, int width, int seed)
    {
        var random = new Random(seed);
        var sample = Form(source).RegressionCases[0].Inputs;
        var arity = SourceArity(source);
        var inputs = new MathBlockValue[arity];
        var seriesIndex = 0;
        for (var index = 0; index < arity; index++)
        {
            var kind = sample[index].Type.Kind;
            if (kind == MathBlockValueKind.BooleanVector)
            {
                var flags = new bool[count];
                for (var row = 0; row < count; row++)
                    flags[row] = random.Next(3) != 0;
                inputs[index] = MathBlockValue.BooleanVector(flags);
            }
            else if (kind == MathBlockValueKind.Vector)
            {
                inputs[index] = MathBlockValue.Vector(
                    CreateSeries(source, seriesIndex, count, width, random),
                    sample[index].Type.Unit);
                seriesIndex++;
            }
            else
            {
                inputs[index] = sample[index];
            }
        }
        return inputs;
    }

    private static double[] CreateSeries(string source, int seriesIndex, int count, int width, Random random)
    {
        var values = new double[count];
        if (source.StartsWith("information.", StringComparison.Ordinal))
        {
            var cell = new double[width];
            var total = 0d;
            for (var index = 0; index < width; index++)
                total += cell[index] = 0.1d + random.NextDouble();
            for (var row = 0; row < count; row++)
                values[row] = cell[row % width] / total;
            for (var row = count / 2; row < Math.Min(count, count / 2 + 3); row++)
                values[row] *= 1.5d;
            return values;
        }
        if (string.Equals(source, "path.zero-crossing-count", StringComparison.Ordinal) ||
            string.Equals(source, "path.turning-point-count", StringComparison.Ordinal))
        {
            for (var row = 0; row < count; row++)
                values[row] = random.Next(8) == 0 ? 0d : random.NextDouble() * 2d - 1d;
            return values;
        }
        if (string.Equals(source, "path.first-passage-index", StringComparison.Ordinal))
        {
            // The sample threshold is 4, so the series crosses it in some windows and not in others.
            for (var row = 0; row < count; row++)
                values[row] = 1d + random.NextDouble() * 3.5d;
            return values;
        }
        if (seriesIndex == 1 && source.StartsWith("statistics.weighted-", StringComparison.Ordinal))
        {
            for (var row = 0; row < count; row++)
                values[row] = random.Next(10) == 0 ? 0d : random.NextDouble();
            return values;
        }
        for (var row = 0; row < count; row++)
        {
            var value = 0.5d + random.NextDouble() * 1.5d;
            values[row] = random.Next(4) == 0 ? Math.Round(value * 4d, MidpointRounding.ToEven) / 4d : value;
        }
        var flatStart = seriesIndex == 0 ? count / 3 : (2 * count) / 3;
        var flatLength = Math.Min(count - flatStart, width + 3);
        for (var row = flatStart; row < flatStart + flatLength; row++)
            values[row] = 1.25d;
        return values;
    }

    // Row t of the reference is the Standard source operation on freshly copied slices t - width + 1 .. t. It does
    // not use the window lift. Rows not in the stride are left unchecked.
    public static (bool[] Checked, bool[] Valid, double[] Values) Reference(
        string source,
        MathBlockValue[] sourceInputs,
        int count,
        int width,
        int stride = 1)
    {
        var operation = MathBlockCatalog.Standard.Get(source);
        var isChecked = new bool[count];
        var valid = new bool[count];
        var values = new double[count];
        var rows = count - width + 1;
        var vectors = new double[]?[sourceInputs.Length];
        var booleanVectors = new bool[]?[sourceInputs.Length];
        for (var index = 0; index < sourceInputs.Length; index++)
        {
            if (sourceInputs[index].Type.Kind == MathBlockValueKind.Vector)
                vectors[index] = sourceInputs[index].AsVector().ToArray();
            else if (sourceInputs[index].Type.Kind == MathBlockValueKind.BooleanVector)
                booleanVectors[index] = sourceInputs[index].AsBooleanVector().ToArray();
        }
        Parallel.For(0, rows, new ParallelOptions { MaxDegreeOfParallelism = 4 }, offset =>
        {
            var end = offset + width - 1;
            if (offset % stride != 0 && end != count - 1)
                return;
            var window = new MathBlockValue[sourceInputs.Length];
            for (var index = 0; index < window.Length; index++)
            {
                var input = sourceInputs[index];
                if (vectors[index] is { } vector)
                    window[index] = MathBlockValue.Vector(vector.AsSpan(offset, width).ToArray(), input.Type.Unit);
                else if (booleanVectors[index] is { } booleanVector)
                    window[index] = MathBlockValue.BooleanVector(booleanVector.AsSpan(offset, width).ToArray());
                else
                    window[index] = input;
            }
            var result = operation.Evaluate(window);
            isChecked[end] = true;
            valid[end] = result.IsValid;
            if (result.IsValid)
            {
                values[end] = result.Type.Kind == MathBlockValueKind.Scalar
                    ? result.AsScalar()
                    : result.AsVector()[width - 1];
            }
        });
        for (var row = 0; row < width - 1; row++)
            isChecked[row] = true;
        return (isChecked, valid, values);
    }

    public static MathBlockValue[] FormInputs(
        MathBlockValue[] sourceInputs,
        int width,
        MathBlockValue fill) =>
        [.. sourceInputs, MathBlockValue.Scalar(width), fill];

    public static MathBlockValue[] ValidityInputs(MathBlockValue[] sourceInputs, int width) =>
        [.. sourceInputs, MathBlockValue.Scalar(width)];

    // Compares a form and its sibling with the reference row by row, bit for bit, and returns readable failures.
    public static List<string> Compare(
        string source,
        int width,
        double fill,
        MathBlockValue form,
        MathBlockValue validity,
        (bool[] Checked, bool[] Valid, double[] Values) reference)
    {
        var failures = new List<string>();
        if (!form.IsValid || !validity.IsValid)
        {
            failures.Add($"{source} w={width}: whole output invalid ({form.InvalidReason ?? validity.InvalidReason}).");
            return failures;
        }
        var values = form.AsVector();
        var flags = validity.AsBooleanVector();
        if (values.Count != reference.Values.Length || flags.Count != reference.Values.Length)
        {
            failures.Add($"{source} w={width}: length {values.Count}/{flags.Count}, expected {reference.Values.Length}.");
            return failures;
        }
        for (var row = 0; row < reference.Values.Length && failures.Count < 8; row++)
        {
            if (!reference.Checked[row])
                continue;
            var expected = reference.Valid[row] ? reference.Values[row] : fill;
            if (BitConverter.DoubleToInt64Bits(values[row]) != BitConverter.DoubleToInt64Bits(expected))
            {
                failures.Add($"{source} w={width} row {row}: value {values[row]:R}, expected {expected:R} " +
                             $"(source {(reference.Valid[row] ? "valid" : "invalid or warm-up")}).");
            }
            if (flags[row] != reference.Valid[row])
                failures.Add($"{source} w={width} row {row}: validity {flags[row]}, expected {reference.Valid[row]}.");
        }
        return failures;
    }
}
