using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The proof bar over a timing table: the ratios to the median class and to the references, and the four assertions. Each assertion collects every failing cell and fails once with
/// the list, so a run reports all of them.
/// </summary>
internal static class ProofBar
{
    /// <summary>The input class that first-true-offset scans in full; it is left out of the median class.</summary>
    internal const string AllFalse = nameof(ProofClass.AllFalse);

    private const double WorstClassFactor = 2d;
    private const double ReferenceFactor = 2d;
    private const double LinearFactor = 2d;
    private const double FullScanFactor = 1.25d;

    /// <summary>Fills in the median over the classes (the all-false class excluded) and the three ratios of every cell.</summary>
    internal static void Annotate(List<ProofCell> cells)
    {
        var groups = new Dictionary<string, List<double>>(StringComparer.Ordinal);
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (string.Equals(cell.ClassName, AllFalse, StringComparison.Ordinal))
                continue;
            if (!groups.TryGetValue(cell.GroupKey, out var list))
            {
                list = [];
                groups.Add(cell.GroupKey, list);
            }

            list.Add(cell.NanosecondsPerRow);
        }

        var medians = new Dictionary<string, double>(StringComparer.Ordinal);
        foreach (var pair in groups)
            medians[pair.Key] = ProofTiming.Median(pair.Value.ToArray());
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            cell.MedianNanosecondsPerRow = medians[cell.GroupKey];
            cell.MedianRatio = cell.NanosecondsPerRow / cell.MedianNanosecondsPerRow;
            cell.ReferenceRatio = cell.ReferenceNanosecondsPerRow > 0d ? cell.NanosecondsPerRow / cell.ReferenceNanosecondsPerRow : 0d;
            cell.SecondReferenceRatio = cell.SecondReferenceNanosecondsPerRow > 0d ? cell.NanosecondsPerRow / cell.SecondReferenceNanosecondsPerRow : 0d;
        }
    }

    /// <summary>Renders the table as tab-separated text, one row per cell.</summary>
    internal static string Render(List<ProofCell> cells) => Render(cells, 0);

    /// <summary>Renders the table as tab-separated text; a positive <paramref name="samples"/> is written into the ns_per_row column header.</summary>
    internal static string Render(List<ProofCell> cells, int samples)
    {
        var column = samples > 0 ? string.Create(CultureInfo.InvariantCulture, $"ns_per_row_median_of_{samples}") : "ns_per_row";
        var text = new StringBuilder(string.Concat("operation\tclass\tcounts\tparameter\twidth\t", column, "\tratio_to_median_class\treference_ns_per_row\tratio_to_reference\tsecond_reference_ns_per_row\tratio_to_second_reference\n"));
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            text.Append(
                CultureInfo.InvariantCulture,
                $"{cell.Operation}\t{cell.ClassName}\t{cell.Counts}\t{cell.Parameter}\t{cell.Width:R}\t{cell.NanosecondsPerRow:F3}\t{cell.MedianRatio:F3}\t{cell.ReferenceNanosecondsPerRow:F3}\t{cell.ReferenceRatio:F3}\t{cell.SecondReferenceNanosecondsPerRow:F3}\t{cell.SecondReferenceRatio:F3}\n");
        }

        return text.ToString();
    }

    /// <summary>Bar (i): at fixed parameters, the worst class costs at most twice the median class. Cells that <paramref name="applies"/> rejects are not checked.</summary>
    internal static void AssertWorstClassWithinTwiceMedian(List<ProofCell> cells, Func<ProofCell, bool> applies)
    {
        var failures = new List<string>();
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (applies(cell) && !string.Equals(cell.ClassName, AllFalse, StringComparison.Ordinal) && cell.MedianRatio > WorstClassFactor)
                failures.Add(Describe(cell, "median class", cell.MedianRatio, WorstClassFactor));
        }

        Fail("Bar (i), worst class against the median class", failures);
    }

    /// <summary>Bar (iv): the median class costs at most twice the reference at the same size. Cells that <paramref name="applies"/> rejects are not checked.</summary>
    internal static void AssertMedianClassWithinTwiceReference(List<ProofCell> cells, Func<ProofCell, bool> applies)
    {
        var failures = new List<string>();
        var seen = new HashSet<string>(StringComparer.Ordinal);
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (!applies(cell) || cell.ReferenceNanosecondsPerRow <= 0d || !seen.Add(cell.GroupKey))
                continue;
            var ratio = cell.MedianNanosecondsPerRow / cell.ReferenceNanosecondsPerRow;
            if (ratio > ReferenceFactor)
                failures.Add(Describe(cell, "reference", ratio, ReferenceFactor));
        }

        Fail("Bar (iv), median class against the reference", failures);
    }

    /// <summary>
    /// Bar (iii): along the parameter, each class's cost per row stays within twice a least-squares line through its own points (never below its smallest cost), and between
    /// neighbouring parameters it grows by at most twice the ratio of the parameters.
    /// </summary>
    internal static void AssertLinearGrowth(List<ProofCell> cells)
    {
        var failures = new List<string>();
        var series = new Dictionary<string, List<ProofCell>>(StringComparer.Ordinal);
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (!series.TryGetValue(cell.SeriesKey, out var list))
            {
                list = [];
                series.Add(cell.SeriesKey, list);
            }

            list.Add(cell);
        }

        foreach (var pair in series)
            CheckSeries(pair.Key, pair.Value, failures);
        Fail("Bar (iii), growth along the parameter", failures);
    }

    /// <summary>
    /// Bar (iii) for first-true-offset: every class costs at most 1.25 times its all-false full-scan class at the same counts class and parameter. A cell that carries a full scan timed
    /// back to back with it is compared with that; any other cell with the all-false cell of the table.
    /// </summary>
    internal static void AssertWithinFullScan(List<ProofCell> cells, Func<ProofCell, bool> applies)
    {
        var failures = new List<string>();
        var scans = new Dictionary<string, double>(StringComparer.Ordinal);
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (applies(cell) && string.Equals(cell.ClassName, AllFalse, StringComparison.Ordinal))
                scans[cell.GroupKey] = cell.NanosecondsPerRow;
        }

        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (!applies(cell) || string.Equals(cell.ClassName, AllFalse, StringComparison.Ordinal))
                continue;
            var scan = cell.FullScanNanosecondsPerRow;
            if (scan <= 0d && !scans.TryGetValue(cell.GroupKey, out scan))
                continue;
            var ratio = cell.NanosecondsPerRow / scan;
            if (ratio > FullScanFactor)
                failures.Add(Describe(cell, "all-false full scan", ratio, FullScanFactor));
        }

        Fail("Bar (iii), early exit against the full scan", failures);
    }

    /// <summary>Fails the test with the collected failures, or passes when there are none.</summary>
    internal static void Fail(string bar, List<string> failures) =>
        Assert.True(failures.Count == 0, bar + ": " + failures.Count.ToString(CultureInfo.InvariantCulture) + " cell(s) over the limit:\n" + string.Join('\n', failures));

    private static string Describe(ProofCell cell, string against, double ratio, double limit) =>
        string.Create(
            CultureInfo.InvariantCulture,
            $"{cell.Operation} class {cell.ClassName} counts {cell.Counts} parameter {cell.Parameter}: {cell.NanosecondsPerRow:F3} ns/row is {ratio:F2} times the {against} (limit {limit:F2})");

    private static void CheckSeries(string key, List<ProofCell> items, List<string> failures)
    {
        items.Sort((left, right) => left.Width.CompareTo(right.Width));
        var count = items.Count;
        if (count < 3)
            return;
        var widths = new double[count];
        var costs = new double[count];
        var floor = double.MaxValue;
        for (var index = 0; index < count; index++)
        {
            widths[index] = items[index].Width;
            costs[index] = items[index].NanosecondsPerRow;
            floor = Math.Min(floor, costs[index]);
        }

        var (intercept, slope) = Fit(widths, costs);
        for (var index = 0; index < count; index++)
        {
            var bound = LinearFactor * Math.Max(intercept + slope * widths[index], floor);
            if (costs[index] > bound)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{key} parameter {items[index].Parameter}: {costs[index]:F3} ns/row is over twice the linear fit {bound / LinearFactor:F3}"));
            if (index > 0 && costs[index] / costs[index - 1] > LinearFactor * widths[index] / widths[index - 1])
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{key} parameter {items[index].Parameter}: cost grew {costs[index] / costs[index - 1]:F2} times from the neighbouring parameter, more than twice the ratio of the parameters"));
        }
    }

    // The ordinary least-squares line through the points.
    private static (double Intercept, double Slope) Fit(double[] widths, double[] costs)
    {
        var count = widths.Length;
        var meanWidth = 0d;
        var meanCost = 0d;
        for (var index = 0; index < count; index++)
        {
            meanWidth += widths[index] / count;
            meanCost += costs[index] / count;
        }

        var covariance = 0d;
        var variance = 0d;
        for (var index = 0; index < count; index++)
        {
            covariance += (widths[index] - meanWidth) * (costs[index] - meanCost);
            variance += (widths[index] - meanWidth) * (widths[index] - meanWidth);
        }

        var slope = variance > 0d ? covariance / variance : 0d;
        return (meanCost - slope * meanWidth, slope);
    }
}
