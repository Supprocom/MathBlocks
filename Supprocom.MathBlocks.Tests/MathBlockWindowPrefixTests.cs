using System.Globalization;
using Xunit.Abstractions;
using static Supprocom.MathBlocks.Tests.MathBlockWindowM2TestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the window-prefix.* forms against exact window sums and variances.</summary>
public sealed class MathBlockWindowPrefixTests(ITestOutputHelper output)
{
    private const double Sentinel = -7_777.5d;

    private static readonly double Unit = MathBlockWindowExactReference.Unit;

    /// <summary>Gets the input families of the exactness tests.</summary>
    public static TheoryData<string> Families => ["random", "offset-1e9", "near-constant", "alternating", "random-walk", "spike"];

    /// <summary>
    /// Verifies every computed row of the six forms is within its stated bound of the exact value, at 3,000 rows and
    /// widths 1, 2, 3, 17 and 96, and that windows whose values are all equal give a variance of exactly 0.
    /// </summary>
    [Theory]
    [MemberData(nameof(Families))]
    public void ErrorsStayWithinTheStatedBounds(string family)
    {
        var x = CreateFamily(family, 3_000, 17);
        var report = new List<string>();
        var failures = new List<string>();
        foreach (var width in new[] { 1, 2, 3, 17, 96 })
            failures.AddRange(CheckBounds(family, x, width, report));
        output.WriteLine(string.Join(Environment.NewLine, report));

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(40)));
    }

    /// <summary>
    /// Verifies a window whose values are all equal has variance and standard deviation +0 exactly, also after
    /// varied rows, whose rounding stays in the prefix sums.
    /// </summary>
    [Fact]
    public void WindowsOfEqualValuesHaveExactlyZeroVariance()
    {
        var random = new Random(5);
        var values = new double[400];
        for (var row = 0; row < values.Length; row++)
            values[row] = row is >= 150 and < 200 ? 1_000.1d : row is >= 300 and < 310 ? -0d : 1_000d + random.NextDouble() * 3d;
        values[305] = 0d;
        var x = MathBlockValue.Vector(values);
        foreach (var name in new[] { "population-variance", "sample-variance", "population-standard-deviation", "sample-standard-deviation" })
        {
            foreach (var width in new[] { 2, 7, 10, 50 })
            {
                var result = PrefixForm(name).Evaluate(x, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel)).AsVector();
                for (var row = width - 1; row < values.Length; row++)
                {
                    var constant = true;
                    for (var index = row - width + 1; index <= row; index++)
                        constant &= values[index] == values[row];
                    if (constant)
                        Assert.True(BitConverter.DoubleToInt64Bits(result[row]) == 0L, $"{name} w={width} row {row}: {result[row]:R}");
                }
            }
        }
    }

    /// <summary>
    /// Verifies the sibling marks exactly the computed rows, with the fill set to a sentinel and to a value that also
    /// occurs as a computed result.
    /// </summary>
    [Fact]
    public void SiblingsMarkExactlyTheComputedRows()
    {
        var random = new Random(9);
        var values = new double[64];
        for (var row = 0; row < values.Length; row++)
            values[row] = row is >= 20 and < 30 ? 2d : random.NextDouble() * 10d;
        var x = MathBlockValue.Vector(values);
        foreach (var name in PrefixNames)
        {
            foreach (var width in new[] { 1, 2, 5, 64 })
            {
                var form = PrefixForm(name);
                var unit = form.ResolveOutputType([x.Type, MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
                var first = form.Evaluate(x, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel, unit)).AsVector().ToArray();
                var valid = PrefixValidity(name).Evaluate(x, MathBlockValue.Scalar(width)).AsBooleanVector().ToArray();
                var sampleWidthOne = width == 1 && name.StartsWith("sample-", StringComparison.Ordinal);
                for (var row = 0; row < values.Length; row++)
                {
                    Assert.Equal(row >= width - 1 && !sampleWidthOne, valid[row]);
                    if (!valid[row])
                        Assert.Equal(Sentinel, first[row]);
                }
                var computed = Array.FindIndex(valid, flag => flag);
                if (computed < 0)
                    continue;
                var realFill = first[computed];
                var second = form.Evaluate(x, MathBlockValue.Scalar(width), MathBlockValue.Scalar(realFill, unit)).AsVector().ToArray();
                for (var row = 0; row < values.Length; row++)
                    Assert.Equal(valid[row] ? first[row] : realFill, second[row]);
            }
        }
    }

    /// <summary>Verifies a prefix that overflows fills every later row and marks it not computed.</summary>
    [Fact]
    public void RowsAfterAPrefixOverflowHoldTheFill()
    {
        var x = MathBlockValue.Vector([1e308d, 1e308d, 1d, 2d, 3d]);
        var sum = PrefixForm("sum").Evaluate(x, MathBlockValue.Scalar(1d), MathBlockValue.Scalar(Sentinel)).AsVector().ToArray();
        var valid = PrefixValidity("sum").Evaluate(x, MathBlockValue.Scalar(1d)).AsBooleanVector().ToArray();

        Assert.Equal([1e308d, Sentinel, Sentinel, Sentinel, Sentinel], sum);
        Assert.Equal([true, false, false, false, false], valid);
    }

    /// <summary>Verifies the declared types carry the series length and the result unit, and the fill must match it.</summary>
    [Fact]
    public void DeclaredTypesCarryTheResultUnit()
    {
        var unit = MathBlockUnit.Basis0;
        var squared = unit.Pow(new MathRational(2));
        var x = MathBlockValue.Vector([1d, 2d, 4d, 8d], unit);
        var width = MathBlockValue.Scalar(2d);

        Assert.Equal(MathBlockType.Vector(unit, 4), PrefixForm("mean").Evaluate(x, width, MathBlockValue.Scalar(0d, unit)).Type);
        Assert.Equal(
            MathBlockType.Vector(squared, 4),
            PrefixForm("sample-variance").Evaluate(x, width, MathBlockValue.Scalar(0d, squared)).Type);
        Assert.Equal(
            MathBlockType.Vector(unit, 4),
            PrefixForm("sample-standard-deviation").Evaluate(x, width, MathBlockValue.Scalar(0d, unit)).Type);
        Assert.Equal(MathBlockType.BooleanVector(4), PrefixValidity("sum").Evaluate(x, width).Type);
        Assert.Throws<InvalidOperationException>(() => PrefixForm("population-variance").Evaluate(x, width, MathBlockValue.Scalar(0d, unit)));
        Assert.False(PrefixForm("sum").Evaluate(x, MathBlockValue.Scalar(5d), MathBlockValue.Scalar(0d, unit)).IsValid);
        Assert.False(PrefixForm("sum").Evaluate(x, MathBlockValue.Scalar(1.5d), MathBlockValue.Scalar(0d, unit)).IsValid);
    }

    /// <summary>Verifies every prefix form and sibling is labelled Trailing with the width input.</summary>
    [Fact]
    public void FormsAndSiblingsAreLabelledTrailingWithTheWidthInput()
    {
        foreach (var name in PrefixNames)
        {
            Assert.Equal(MathBlockCausality.Trailing, PrefixForm(name).Causality.Kind);
            Assert.Equal(1, PrefixForm(name).Causality.WidthInputIndex);
            Assert.Equal(MathBlockCausality.Trailing, PrefixValidity(name).Causality.Kind);
            Assert.Equal(1, PrefixValidity(name).Causality.WidthInputIndex);
        }
    }

    // Seeded input families: uniform values; values near 1e9; near-constant values with runs of exactly equal values;
    // alternating values near 1e100 and 1e-100; a random walk near 1e5; standard normal values with one spike of 1e8.
    internal static double[] CreateFamily(string family, int count, int seed)
    {
        var random = new Random(seed);
        var values = new double[count];
        var level = 1e5d;
        for (var row = 0; row < count; row++)
        {
            values[row] = family switch
            {
                "random" => random.NextDouble() * 200d - 100d,
                "offset-1e9" => 1e9d + (random.NextDouble() * 2d - 1d),
                "near-constant" => row / 200 % 3 == 1
                    ? 1e5d + 0.25d * (row / 600)
                    : 1e5d + 1e-7d * (random.NextDouble() * 2d - 1d),
                "alternating" => row % 2 == 0
                    ? (random.Next(2) == 0 ? -1d : 1d) * 1e100d * (1d + 1e-3d * random.NextDouble())
                    : 1e-100d * (1d + random.NextDouble()),
                "random-walk" => level += 10d * Normal(random),
                "spike" => row == 10 ? 1e8d : Normal(random),
                _ => throw new ArgumentOutOfRangeException(nameof(family), family, "Unknown family.")
            };
        }
        return values;
    }

    // Checks every computed row of the six forms at one width against the exact reference. Appends one report line per
    // form with the worst ratio of error to the stated bound and, for the variance forms, to the bound without the
    // prefix history term (the form written in design section 3), and the worst relative error. Only the stated bound
    // is asserted: the design form omits the rounding of the prefix sums over the rows before the window, which the
    // spike family exceeds at any length and the other families exceed at 302,893 rows.
    internal static List<string> CheckBounds(string family, double[] x, int width, List<string> report)
    {
        var failures = new List<string>();
        var reference = new MathBlockWindowExactReference(x);
        var series = MathBlockValue.Vector(x);
        foreach (var name in PrefixNames)
        {
            var value = PrefixForm(name).Evaluate(series, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel));
            var validity = PrefixValidity(name).Evaluate(series, MathBlockValue.Scalar(width));
            if (!value.IsValid || !validity.IsValid)
            {
                failures.Add($"{family} {name} w={width}: invalid output ({value.InvalidReason ?? validity.InvalidReason})");
                continue;
            }
            var values = value.AsVector().ToArray();
            var computed = validity.AsBooleanVector().ToArray();
            var expectComputed = !(width == 1 && name.StartsWith("sample-", StringComparison.Ordinal));
            var worst = 0d;
            var worstDesign = 0d;
            var worstRow = -1;
            var worstDesignRow = -1;
            var worstRelative = 0d;
            var worstRelativeRow = -1;
            for (var row = width - 1; row < x.Length; row++)
            {
                var where = $"{family} {name} w={width} row {row}";
                if (computed[row] != expectComputed)
                {
                    failures.Add($"{where}: computed {computed[row]}, expected {expectComputed}");
                    continue;
                }
                if (!expectComputed || !Measure(reference, name, values[row], row, width, where, failures, out var error, out var bound, out var designBound))
                    continue;
                var ratio = Ratio(error, bound);
                if (!(ratio <= 1d))
                {
                    failures.Add(string.Create(
                        CultureInfo.InvariantCulture,
                        $"{where}: error {error:E3} exceeds bound {bound:E3} (ratio {ratio:G4})"));
                }
                if (ratio > worst)
                    (worst, worstRow) = (ratio, row);
                var designRatio = Ratio(error, designBound);
                if (designRatio > worstDesign)
                    (worstDesign, worstDesignRow) = (designRatio, row);
                var relative = Ratio(error, Math.Abs(Exact(reference, name, row, width)));
                if (relative > worstRelative)
                    (worstRelative, worstRelativeRow) = (relative, row);
            }
            var design = name.EndsWith("variance", StringComparison.Ordinal) || name.EndsWith("deviation", StringComparison.Ordinal)
                ? worstDesign.ToString("G6", CultureInfo.InvariantCulture)
                : "n/a";
            report.Add(string.Create(
                CultureInfo.InvariantCulture,
                $"{family}\tn={x.Length}\tw={width}\t{name}\tworst-ratio={worst:G6}\trow={worstRow}\tworst-design-form-ratio={design}\trow={worstDesignRow}\tworst-relative-error={worstRelative:G6}\trow={worstRelativeRow}"));
        }
        return failures;
    }

    // The exact error of one computed row and its bounds. Returns false for a constant window, whose variance must be
    // +0 exactly, after recording a failure when it isn't. The design-form bound is the variance bound without the
    // prefix history term, and the stated bound for the sum and the mean.
    private static bool Measure(
        MathBlockWindowExactReference reference,
        string name,
        double value,
        int row,
        int width,
        string where,
        List<string> failures,
        out double error,
        out double bound,
        out double designBound)
    {
        var sample = name.StartsWith("sample-", StringComparison.Ordinal);
        switch (name)
        {
            case "sum":
                error = reference.SumError(value, row, width);
                bound = designBound = SumBound(reference, row, width);
                return true;
            case "mean":
                error = reference.MeanError(value, row, width);
                bound = designBound = (1d + Unit) * SumBound(reference, row, width) / width +
                                      Unit * Math.Abs(reference.Sum(row, width) / width);
                return true;
        }
        if (reference.VarianceIsZero(row, width))
        {
            if (BitConverter.DoubleToInt64Bits(value) != 0L)
                failures.Add($"{where}: {value:R} on a constant window, expected +0");
            error = bound = designBound = 0d;
            return false;
        }
        var variance = reference.Variance(row, width, sample);
        VarianceBounds(reference, row, width, sample, variance, out var full, out var design);
        if (name.EndsWith("standard-deviation", StringComparison.Ordinal))
        {
            error = reference.StandardDeviationError(value, row, width, sample);
            bound = DeviationBound(variance, full);
            designBound = DeviationBound(variance, design);
        }
        else
        {
            error = reference.VarianceError(value, row, width, sample);
            bound = full;
            designBound = design;
        }
        return true;
    }

    private static double Exact(MathBlockWindowExactReference reference, string name, int row, int width)
    {
        var sample = name.StartsWith("sample-", StringComparison.Ordinal);
        return name switch
        {
            "sum" => reference.Sum(row, width),
            "mean" => reference.Sum(row, width) / width,
            _ when name.EndsWith("standard-deviation", StringComparison.Ordinal) => Math.Sqrt(reference.Variance(row, width, sample)),
            _ => reference.Variance(row, width, sample)
        };
    }

    private static double Ratio(double error, double bound) =>
        bound > 0d ? error / bound : error == 0d ? 0d : double.PositiveInfinity;

    // u |s| + gamma(2t)^2 sum_{i <= t} |x_i|.
    internal static double SumBound(MathBlockWindowExactReference reference, int row, int width)
    {
        var gamma = MathBlockWindowExactReference.Gamma(2d * row);
        return Unit * Math.Abs(reference.Sum(row, width)) + gamma * gamma * reference.AbsoluteHistory(row);
    }

    // design = 2u v + 27 u^2 kappa v; full = design + the prefix history term h_t.
    internal static void VarianceBounds(
        MathBlockWindowExactReference reference,
        int row,
        int width,
        bool sample,
        double variance,
        out double full,
        out double design)
    {
        var populationVariance = sample ? variance * (width - 1) / width : variance;
        var kappa = 1d + reference.ShiftedMeanSquare(row, width) / populationVariance;
        design = 2d * Unit * variance + 27d * Unit * Unit * kappa * variance;
        var gamma = MathBlockWindowExactReference.Gamma(2d * row + 6d);
        var historyFirst = gamma * gamma * reference.ShiftedAbsoluteHistory(row);
        var historySecond = gamma * gamma * reference.ShiftedSquareHistory(row);
        var divisor = sample ? width - 1d : width;
        var history = (1d + 3d * Unit) *
                      (historySecond + (2d * reference.ShiftedWindowAbsoluteSum(row, width) + historyFirst) * historyFirst / width) /
                      divisor;
        full = design + history;
    }

    // min(B / (sqrt(max(v - B, 0)) + sqrt(v)), sqrt(B)) + (3u/2 + 4u^2) sqrt(v + B). The forms take the root with
    // MathBlockPrimitives.Sqrt, whose Newton steps end within 3u/2 + O(u^2) of the exact root, not with a correctly
    // rounded square root.
    internal static double DeviationBound(double variance, double varianceBound)
    {
        var root = Math.Sqrt(variance);
        var lower = Math.Sqrt(Math.Max(variance - varianceBound, 0d));
        var difference = Math.Min(varianceBound / (lower + root), Math.Sqrt(varianceBound));
        return difference + (1.5d * Unit + 4d * Unit * Unit) * Math.Sqrt(variance + varianceBound);
    }

    private static double Normal(Random random)
    {
        var first = 1d - random.NextDouble();
        var second = random.NextDouble();
        return Math.Sqrt(-2d * Math.Log(first)) * Math.Cos(2d * Math.PI * second);
    }
}
