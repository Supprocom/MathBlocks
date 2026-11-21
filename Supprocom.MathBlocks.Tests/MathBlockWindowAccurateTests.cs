using System.Globalization;
using Xunit.Abstractions;
using static Supprocom.MathBlocks.Tests.MathBlockWindowM2TestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the window-accurate.* forms against exact window sums and variances.</summary>
public sealed class MathBlockWindowAccurateTests(ITestOutputHelper output)
{
    private const float Sentinel = -7_777.5f;

    private static readonly float Unit = MathBlockWindowExactReference.Unit;

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
    /// varied rows.
    /// </summary>
    [Fact]
    public void WindowsOfEqualValuesHaveExactlyZeroVariance()
    {
        // Runs of 60 equal values with full significands and magnitudes from 1e-50 to 1e50, where the double-double
        // steps alone leave a nonzero M about a third of the time, between varied rows; and a run of signed zeros.
        var random = new Random(5);
        var values = new float[4_000];
        var constant = 0f;
        for (var row = 0; row < values.Length; row++)
        {
            if (row % 80 == 0)
                constant = (random.NextSingle() * 2f - 1f) * MathF.Pow(10f, random.Next(-50, 51));
            values[row] = row % 80 < 60 ? constant : 1_000f + random.NextSingle() * 3f;
        }
        values[160] = -1.0101787042252373e+32f;
        for (var row = 161; row < 220; row++)
            values[row] = values[160];
        for (var row = 300; row < 310; row++)
            values[row] = row == 305 ? 0f : -0f;
        var x = MathBlockValue.Vector(values);
        foreach (var name in new[] { "population-variance", "sample-variance", "population-standard-deviation", "sample-standard-deviation" })
        {
            foreach (var width in new[] { 2, 7, 10, 50 })
            {
                var result = AccurateForm(name).Evaluate(x, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel)).AsVector();
                for (var row = width - 1; row < values.Length; row++)
                {
                    var equal = true;
                    for (var index = row - width + 1; index <= row; index++)
                        equal &= values[index] == values[row];
                    if (equal)
                        Assert.True(BitConverter.SingleToInt32Bits(result[row]) == 0L, $"{name} w={width} row {row}: {result[row]:R}");
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
        var values = new float[64];
        for (var row = 0; row < values.Length; row++)
            values[row] = row is >= 20 and < 30 ? 2f : random.NextSingle() * 10f;
        var x = MathBlockValue.Vector(values);
        foreach (var name in AccurateNames)
        {
            foreach (var width in new[] { 1, 2, 5, 64 })
            {
                var form = AccurateForm(name);
                var unit = form.ResolveOutputType([x.Type, MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit;
                var first = form.Evaluate(x, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel, unit)).AsVector().ToArray();
                var valid = AccurateValidity(name).Evaluate(x, MathBlockValue.Scalar(width)).AsBooleanVector().ToArray();
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

    /// <summary>
    /// Verifies only a window whose sum overflows holds the fill: the exact sums recover after it, and a window of
    /// huge values with a representable sum is computed.
    /// </summary>
    [Fact]
    public void OnlyWindowsWhoseResultOverflowsHoldTheFill()
    {
        var x = MathBlockValue.Vector([3.16e38f, 3.16e38f, -3.16e38f, 2f, 3f]);
        var sum = AccurateForm("sum").Evaluate(x, MathBlockValue.Scalar(2f), MathBlockValue.Scalar(Sentinel)).AsVector().ToArray();
        var valid = AccurateValidity("sum").Evaluate(x, MathBlockValue.Scalar(2f)).AsBooleanVector().ToArray();
        var wide = AccurateForm("sum").Evaluate(x, MathBlockValue.Scalar(3f), MathBlockValue.Scalar(Sentinel)).AsVector().ToArray();

        Assert.Equal([Sentinel, Sentinel, 0f, -3.16e38f, 5f], sum);
        Assert.Equal([false, false, true, true, true], valid);
        Assert.Equal([Sentinel, Sentinel, 3.16e38f, 3.16e38f - 3.16e38f + 2f, -3.16e38f + 5f], wide);
    }

    /// <summary>
    /// Verifies variance and deviation rows whose double-double steps would underflow (S2, S1^2, S1^2 / w or M below
    /// 2^-968) or overflow (S1^2 / w above 2^996, or S1^2 not finite) hold the fill and are marked not computed,
    /// while the sum and the mean of the same windows and windows inside the range stay computed.
    /// </summary>
    [Fact]
    public void RowsOutsideTheDoubleDoubleRangeHoldTheFill()
    {
        var tiny = MathBlockValue.Vector([1.88e-20f, 2.05e-20f, 2.15e-20f, 2.23e-20f]);
        var huge = MathBlockValue.Vector([1.63e19f, 1.63e19f, 1.63e19f, 1.63e19f]);
        var large = MathBlockValue.Vector([5.62e18f, 5.69e18f, 5.62e18f, 5.69e18f]);
        var inside = MathBlockValue.Vector([4.69e-13f, 5.11e-13f, 4.22e18f, 4.27e18f]);
        var width = MathBlockValue.Scalar(2f);
        foreach (var name in new[] { "population-variance", "sample-variance", "population-standard-deviation", "sample-standard-deviation" })
        {
            Assert.Equal(
                [Sentinel, Sentinel, Sentinel, Sentinel],
                AccurateForm(name).Evaluate(tiny, width, MathBlockValue.Scalar(Sentinel)).AsVector().ToArray());
            Assert.Equal([false, false, false, false], AccurateValidity(name).Evaluate(tiny, width).AsBooleanVector().ToArray());
            Assert.Equal(
                [false, false, false, false],
                AccurateValidity(name).Evaluate(huge, MathBlockValue.Scalar(3f)).AsBooleanVector().ToArray());
            Assert.Equal([false, false, false, false], AccurateValidity(name).Evaluate(large, width).AsBooleanVector().ToArray());
            Assert.Equal([false, true, true, true], AccurateValidity(name).Evaluate(inside, width).AsBooleanVector().ToArray());
        }
        foreach (var name in new[] { "sum", "mean" })
            Assert.Equal([false, true, true, true], AccurateValidity(name).Evaluate(tiny, width).AsBooleanVector().ToArray());
    }

    /// <summary>
    /// Verifies a variance or deviation row whose exact S2 = sum x^2 is nonzero but rounds to 0, or whose S1 is
    /// nonzero while S1^2 rounds to 0, holds the fill with the sibling false: [5e-324, -5e-324] (S2 = 2^-2147) and
    /// [1e-140, -1e-140, 1e-170] (S1 = 1e-170, S1^2 about 1e-340, S2 in range). The sums and means of those windows,
    /// and a window of exact zeros (variance +0), stay computed.
    /// </summary>
    [Fact]
    public void WindowsWhoseExactSquareSumsRoundToZeroHoldTheFill()
    {
        var cases = new (float[] Values, int Width, bool[] VarianceComputed)[]
        {
            ([1.4e-45f, -1.4e-45f], 2, [false, false]),
            ([5.49e-18f, -5.49e-18f, 1.1e-21f], 3, [false, false, false]),
            ([0f, 0f, -0f], 2, [false, true, true])
        };
        var failures = new List<string>();
        foreach (var (values, width, varianceComputed) in cases)
        {
            var x = MathBlockValue.Vector(values);
            var w = MathBlockValue.Scalar(width);
            foreach (var name in AccurateNames)
            {
                var valid = AccurateValidity(name).Evaluate(x, w).AsBooleanVector().ToArray();
                var rows = AccurateForm(name).Evaluate(x, w, MathBlockValue.Scalar(Sentinel)).AsVector().ToArray();
                for (var row = 0; row < values.Length; row++)
                {
                    var expected = string.Equals(name, "sum", StringComparison.Ordinal) || string.Equals(name, "mean", StringComparison.Ordinal)
                        ? row >= width - 1
                        : varianceComputed[row];
                    if (expected != valid[row])
                        failures.Add($"{name} {string.Join(", ", values)} w={width} row {row}: computed {valid[row]}, expected {expected}");
                    if (!valid[row] && rows[row] != Sentinel)
                        failures.Add($"{name} {string.Join(", ", values)} w={width} row {row}: {rows[row]:R}, expected the fill");
                }
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>
    /// Verifies squares of the smallest doubles fit the accumulator: subnormal and near-subnormal values, whose
    /// scaled square or Dekker error term has significand bits below 2^-2176, give a valid result. The sums and means
    /// are the exact values correctly rounded, which double addition and one division give here because every value
    /// is a multiple of 2^-1074 below 2^-1000; the variance and deviation rows hold the fill or a value of at least
    /// +0.
    /// </summary>
    [Fact]
    public void SquaresOfTheSmallestValuesStayInsideTheAccumulator()
    {
        float[] values = [1.4e-45f, -1.4e-45f, 5.28e-41f, 1.19e-38f, -1.4e-45f, 0f, float.Epsilon, 1.4e-45f, -1.16e-38f, 3.7e-45f];
        var x = MathBlockValue.Vector(values);
        foreach (var width in new[] { 1, 2, 3, values.Length })
        {
            var w = MathBlockValue.Scalar(width);
            foreach (var name in AccurateNames)
            {
                var result = AccurateForm(name).Evaluate(x, w, MathBlockValue.Scalar(Sentinel));
                var valid = AccurateValidity(name).Evaluate(x, w);
                Assert.True(result.IsValid, $"{name} w={width}: {result.InvalidReason}");
                Assert.True(valid.IsValid, $"{name} sibling w={width}: {valid.InvalidReason}");
                var rows = result.AsVector().ToArray();
                for (var row = width - 1; row < values.Length; row++)
                {
                    var sum = 0f;
                    for (var index = row - width + 1; index <= row; index++)
                        sum += values[index];
                    if (name is not ("sum" or "mean"))
                    {
                        Assert.True(rows[row] == Sentinel || rows[row] >= 0f, $"{name} w={width} row {row}: {rows[row]:R}");
                        continue;
                    }
                    var expected = string.Equals(name, "sum", StringComparison.Ordinal) ? sum : sum / width;
                    Assert.True(
                        BitConverter.SingleToInt32Bits(expected) == BitConverter.SingleToInt32Bits(rows[row]),
                        $"{name} w={width} row {row}: {rows[row]:R}, expected {expected:R}");
                }
            }
        }
    }

    /// <summary>
    /// Verifies every form's and sibling's rows depend only on the window: changing every row before row n/2 (also
    /// row 0) leaves every row whose window starts at n/2 or later bit-identical, on the spike, random-walk and
    /// near-constant families.
    /// </summary>
    [Fact]
    public void RowsDependOnlyOnTheirWindow()
    {
        const int count = 4_000;
        var failures = new List<string>();
        foreach (var family in new[] { "spike", "random-walk", "near-constant", "offset-1e9" })
        {
            var first = CreateFamily(family, count, 11);
            var second = CreateFamily(family, count, 12);
            Array.Copy(first, count / 2, second, count / 2, count - count / 2);
            foreach (var width in new[] { 2, 17, 96 })
            {
                foreach (var name in AccurateNames)
                {
                    var a = AccurateForm(name).Evaluate(MathBlockValue.Vector(first), MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel)).AsVector().ToArray();
                    var b = AccurateForm(name).Evaluate(MathBlockValue.Vector(second), MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel)).AsVector().ToArray();
                    var va = AccurateValidity(name).Evaluate(MathBlockValue.Vector(first), MathBlockValue.Scalar(width)).AsBooleanVector().ToArray();
                    var vb = AccurateValidity(name).Evaluate(MathBlockValue.Vector(second), MathBlockValue.Scalar(width)).AsBooleanVector().ToArray();
                    var changed = 0;
                    for (var row = count / 2 + width - 1; row < count; row++)
                    {
                        if (BitConverter.SingleToInt32Bits(a[row]) != BitConverter.SingleToInt32Bits(b[row]) || va[row] != vb[row])
                            changed++;
                    }
                    if (changed != 0)
                        failures.Add($"{family} {name} w={width}: {changed} rows changed");
                }
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>Verifies M5's causality property check accepts the Trailing label of every form and sibling.</summary>
    [Fact]
    [Trait("Category", "CausalityContract")]
    public void TheCausalityCheckAcceptsTheTrailingLabels()
    {
        var failures = new List<string>();
        foreach (var name in AccurateNames)
        {
            failures.AddRange(MathBlockCausalityChecks.Check(AccurateForm(name)));
            failures.AddRange(MathBlockCausalityChecks.Check(AccurateValidity(name)));
        }

        Assert.True(failures.Count == 0, MathBlockCausalityChecks.Format(failures));
    }

    /// <summary>Verifies the declared types carry the series length and the result unit, and the fill must match it.</summary>
    [Fact]
    public void DeclaredTypesCarryTheResultUnit()
    {
        var unit = MathBlockUnit.Basis0;
        var squared = unit.Pow(new MathRational(2));
        var x = MathBlockValue.Vector([1f, 2f, 4f, 8f], unit);
        var width = MathBlockValue.Scalar(2f);

        Assert.Equal(MathBlockType.Vector(unit, 4), AccurateForm("mean").Evaluate(x, width, MathBlockValue.Scalar(0f, unit)).Type);
        Assert.Equal(
            MathBlockType.Vector(squared, 4),
            AccurateForm("sample-variance").Evaluate(x, width, MathBlockValue.Scalar(0f, squared)).Type);
        Assert.Equal(
            MathBlockType.Vector(unit, 4),
            AccurateForm("sample-standard-deviation").Evaluate(x, width, MathBlockValue.Scalar(0f, unit)).Type);
        Assert.Equal(MathBlockType.BooleanVector(4), AccurateValidity("sum").Evaluate(x, width).Type);
        Assert.Throws<InvalidOperationException>(() => AccurateForm("population-variance").Evaluate(x, width, MathBlockValue.Scalar(0f, unit)));
        Assert.False(AccurateForm("sum").Evaluate(x, MathBlockValue.Scalar(5f), MathBlockValue.Scalar(0f, unit)).IsValid);
        Assert.False(AccurateForm("sum").Evaluate(x, MathBlockValue.Scalar(1.5f), MathBlockValue.Scalar(0f, unit)).IsValid);
    }

    /// <summary>Verifies every accurate form and sibling is labelled Trailing with the width input.</summary>
    [Fact]
    public void FormsAndSiblingsAreLabelledTrailingWithTheWidthInput()
    {
        foreach (var name in AccurateNames)
        {
            Assert.Equal(MathBlockCausality.Trailing, AccurateForm(name).Causality.Kind);
            Assert.Equal(1, AccurateForm(name).Causality.WidthInputIndex);
            Assert.Equal(MathBlockCausality.Trailing, AccurateValidity(name).Causality.Kind);
            Assert.Equal(1, AccurateValidity(name).Causality.WidthInputIndex);
        }
    }

    // Seeded input families: uniform values; values near 1e9; near-constant values with runs of exactly equal values;
    // alternating values near 1e100 and 1e-100; a random walk near 1e5; standard normal values with one spike of 1e8.
    internal static float[] CreateFamily(string family, int count, int seed)
    {
        var random = new Random(seed);
        var values = new float[count];
        var level = 1e5f;
        for (var row = 0; row < count; row++)
        {
            values[row] = family switch
            {
                "random" => random.NextSingle() * 200f - 100f,
                "offset-1e9" => 1e9f + (random.NextSingle() * 2f - 1f),
                "near-constant" => row / 200 % 3 == 1
                    ? 1e5f + 0.25f * (row / 600)
                    : 1e5f + 1e-7f * (random.NextSingle() * 2f - 1f),
                "alternating" => row % 2 == 0
                    ? (random.Next(2) == 0 ? -1f : 1f) * 3.16e12f * (1f + 1e-3f * random.NextSingle())
                    : 4.69e-13f * (1f + random.NextSingle()),
                "random-walk" => level += 10f * Normal(random),
                "spike" => row == 10 ? 1e8f : Normal(random),
                _ => throw new ArgumentOutOfRangeException(nameof(family), family, "Unknown family.")
            };
        }
        return values;
    }

    // The square-root error MathBlockPrimitives.Sqrt reaches today (Newton steps, within 3u/2 + O(u^2) of the
    // root). With a correctly rounded square root it is u, and the standard-deviation bound below tightens with it.
    private static readonly float SquareRootError = 1.5f * Unit + 4f * Unit * Unit;

    // Checks every computed row of the six forms at one width against the exact reference: the sum and the mean
    // equal the exact values correctly rounded, bit for bit; the variances and deviations are within their stated
    // bounds, and constant windows give +0. Appends one report line per form with the worst ratio of error to the
    // bound (for the sum and the mean, to u times the exact value) and the worst relative error.
    internal static List<string> CheckBounds(string family, float[] x, int width, List<string> report)
    {
        var failures = new List<string>();
        var reference = new MathBlockWindowExactReference(x);
        var series = MathBlockValue.Vector(x);
        foreach (var name in AccurateNames)
        {
            var value = AccurateForm(name).Evaluate(series, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel));
            var validity = AccurateValidity(name).Evaluate(series, MathBlockValue.Scalar(width));
            if (!value.IsValid || !validity.IsValid)
            {
                failures.Add($"{family} {name} w={width}: invalid output ({value.InvalidReason ?? validity.InvalidReason})");
                continue;
            }
            var values = value.AsVector().ToArray();
            var computed = validity.AsBooleanVector().ToArray();
            var expectComputed = !(width == 1 && name.StartsWith("sample-", StringComparison.Ordinal));
            var worst = 0f;
            var worstRow = -1;
            var worstRelative = 0f;
            var worstRelativeRow = -1;
            for (var row = width - 1; row < x.Length; row++)
            {
                var where = $"{family} {name} w={width} row {row}";
                if (computed[row] != expectComputed)
                {
                    failures.Add($"{where}: computed {computed[row]}, expected {expectComputed}");
                    continue;
                }
                if (!expectComputed || !Measure(reference, name, values[row], row, width, where, failures, out var error, out var bound, out var exact))
                    continue;
                var ratio = Ratio(error, bound);
                if (!(ratio <= 1f))
                {
                    failures.Add(string.Create(
                        CultureInfo.InvariantCulture,
                        $"{where}: error {error:E3} exceeds bound {bound:E3} (ratio {ratio:G4})"));
                }
                if (ratio > worst)
                    (worst, worstRow) = (ratio, row);
                var relative = Ratio(error, Math.Abs(exact));
                if (relative > worstRelative)
                    (worstRelative, worstRelativeRow) = (relative, row);
            }
            report.Add(string.Create(
                CultureInfo.InvariantCulture,
                $"{family}\tn={x.Length}\tw={width}\t{name}\tworst-ratio={worst:G6}\trow={worstRow}\tworst-relative-error={worstRelative:G6}\trow={worstRelativeRow}"));
        }
        return failures;
    }

    // The exact error of one computed row, its bound and the exact value. The sum and the mean must equal the
    // correctly rounded exact value (a failure is recorded otherwise) and report their error against u |exact|.
    // Returns false for a constant window, whose variance must be +0 exactly.
    private static bool Measure(
        MathBlockWindowExactReference reference,
        string name,
        float value,
        int row,
        int width,
        string where,
        List<string> failures,
        out float error,
        out float bound,
        out float exact)
    {
        var sample = name.StartsWith("sample-", StringComparison.Ordinal);
        switch (name)
        {
            case "sum":
            case "mean":
                {
                    var mean = string.Equals(name, "mean", StringComparison.Ordinal);
                    var rounded = mean ? reference.RoundedMean(row, width) : reference.RoundedSum(row, width);
                    if (BitConverter.SingleToInt32Bits(value) != BitConverter.SingleToInt32Bits(rounded))
                        failures.Add($"{where}: {value:R}, expected the correctly rounded {rounded:R}");
                    error = mean ? reference.MeanError(value, row, width) : reference.SumError(value, row, width);
                    exact = mean ? reference.Sum(row, width) / width : reference.Sum(row, width);
                    bound = Unit * Math.Abs(exact);
                    return true;
                }
        }
        if (reference.VarianceIsZero(row, width))
        {
            if (BitConverter.SingleToInt32Bits(value) != 0L)
                failures.Add($"{where}: {value:R} on a constant window, expected +0");
            error = bound = exact = 0f;
            return false;
        }
        var variance = reference.Variance(row, width, sample);
        var varianceBound = VarianceBound(reference, row, width, sample, variance);
        if (name.EndsWith("standard-deviation", StringComparison.Ordinal))
        {
            error = reference.StandardDeviationError(value, row, width, sample);
            bound = DeviationBound(variance, varianceBound);
            exact = MathF.Sqrt(variance);
        }
        else
        {
            error = reference.VarianceError(value, row, width, sample);
            bound = varianceBound;
            exact = variance;
        }
        return true;
    }

    private static float Ratio(float error, float bound) =>
        bound > 0f ? error / bound : error == 0f ? 0f : float.PositiveInfinity;

    // 2u v + 18 u^2 kappa v, kappa = 1 + m^2 / v_population.
    internal static float VarianceBound(
        MathBlockWindowExactReference reference,
        int row,
        int width,
        bool sample,
        float variance)
    {
        var populationVariance = sample ? variance * (width - 1) / width : variance;
        var kappa = 1f + reference.MeanSquare(row, width) / populationVariance;
        return 2f * Unit * variance + 18f * Unit * Unit * kappa * variance;
    }

    // min(B / (sqrt(max(v - B, 0)) + sqrt(v)), sqrt(B)) + e sqrt(v + B), e the square-root error.
    internal static float DeviationBound(float variance, float varianceBound)
    {
        var root = MathF.Sqrt(variance);
        var lower = MathF.Sqrt(Math.Max(variance - varianceBound, 0f));
        var difference = Math.Min(varianceBound / (lower + root), MathF.Sqrt(varianceBound));
        return difference + SquareRootError * MathF.Sqrt(variance + varianceBound);
    }

    private static float Normal(Random random)
    {
        var first = 1f - random.NextSingle();
        var second = random.NextSingle();
        return MathF.Sqrt(-2f * MathF.Log(first)) * MathF.Cos(2f * MathF.PI * second);
    }
}
