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

    /// <summary>The title of the bar Bar (i).</summary>
    internal const string WorstClassBar = "Bar (i), worst class against the median class";

    /// <summary>The title of the bar Bar (iv).</summary>
    internal const string ReferenceBar = "Bar (iv), median class against the reference";

    /// <summary>The title of the bar Bar (iii).</summary>
    internal const string GrowthBar = "Bar (iii), growth along the parameter";

    /// <summary>The title of the bar Bar (iii).</summary>
    internal const string FullScanBar = "Bar (iii), early exit against the full scan (median of each class)";

    /// <summary>The title of the bar of the cells that are judged against the reference on their own class.</summary>
    internal const string SameClassBar = "Bar (iv), class against the reference timed on the same data";

    private const float WorstClassFactor = 2f;
    private const float ReferenceFactor = 2f;
    private const float LinearFactor = 2f;
    private const float FullScanFactor = 1.25f;

    /// <summary>Fills in the median over the classes (the all-false class excluded) and the three ratios of every cell.</summary>
    internal static void Annotate(List<ProofCell> cells)
    {
        var groups = new Dictionary<string, List<float>>(StringComparer.Ordinal);
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

        var medians = new Dictionary<string, float>(StringComparer.Ordinal);
        foreach (var pair in groups)
            medians[pair.Key] = ProofTiming.Median(pair.Value.ToArray());
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            cell.MedianNanosecondsPerRow = medians[cell.GroupKey];
            cell.MedianRatio = cell.NanosecondsPerRow / cell.MedianNanosecondsPerRow;
            cell.ReferenceRatio = cell.ReferenceNanosecondsPerRow > 0f ? cell.NanosecondsPerRow / cell.ReferenceNanosecondsPerRow : 0f;
            cell.SecondReferenceRatio = cell.SecondReferenceNanosecondsPerRow > 0f ? cell.NanosecondsPerRow / cell.SecondReferenceNanosecondsPerRow : 0f;
        }
    }

    /// <summary>Renders the table as tab-separated text, one row per cell.</summary>
    internal static string Render(List<ProofCell> cells) => Render(cells, 0);

    /// <summary>Renders the table as tab-separated text; a positive <paramref name="samples"/> is written into the ns_per_row column header.</summary>
    internal static string Render(List<ProofCell> cells, int samples)
    {
        var column = samples > 0 ? string.Create(CultureInfo.InvariantCulture, $"ns_per_row_median_of_{samples}") : "ns_per_row";
        var text = new StringBuilder(string.Concat("operation\tclass\tcounts\tparameter\twidth\t", column, "\tratio_to_median_class\treference_ns_per_row\tratio_to_reference\tsecond_reference_ns_per_row\tratio_to_second_reference", samples > 0 ? "\tsame_class_reference_ns_per_row\n" : "\n"));
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            var tail = string.Empty;
            if (samples > 0)
                tail = cell.SameClassReferenceNanosecondsPerRow > 0f ? string.Create(CultureInfo.InvariantCulture, $"\t{cell.SameClassReferenceNanosecondsPerRow:F3}") : "\t";
            text.Append(
                CultureInfo.InvariantCulture,
                $"{cell.Operation}\t{cell.ClassName}\t{cell.Counts}\t{cell.Parameter}\t{cell.Width:R}\t{cell.NanosecondsPerRow:F3}\t{cell.MedianRatio:F3}\t{cell.ReferenceNanosecondsPerRow:F3}\t{cell.ReferenceRatio:F3}\t{cell.SecondReferenceNanosecondsPerRow:F3}\t{cell.SecondReferenceRatio:F3}{tail}\n");
        }

        return text.ToString();
    }

    /// <summary>Bar (i): at fixed parameters, the worst class costs at most twice the median class. Cells that <paramref name="applies"/> rejects are not checked.</summary>
    internal static List<string> CollectWorstClassWithinTwiceMedian(List<ProofCell> cells, Func<ProofCell, bool> applies)
    {
        var failures = new List<string>();
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (applies(cell) && !string.Equals(cell.ClassName, AllFalse, StringComparison.Ordinal) && cell.MedianRatio > WorstClassFactor)
                failures.Add(Describe(cell, "median class", cell.MedianRatio, WorstClassFactor));
        }

        return failures;
    }

    /// <summary>Fails the test when this bar has failures; the same check as <see cref="CollectWorstClassWithinTwiceMedian"/>.</summary>
    internal static void AssertWorstClassWithinTwiceMedian(List<ProofCell> cells, Func<ProofCell, bool> applies) => Fail(WorstClassBar, CollectWorstClassWithinTwiceMedian(cells, applies));

    /// <summary>Bar (iv): the median class costs at most twice the reference at the same size. Cells that <paramref name="applies"/> rejects are not checked.</summary>
    internal static List<string> CollectMedianClassWithinTwiceReference(List<ProofCell> cells, Func<ProofCell, bool> applies)
    {
        var failures = new List<string>();
        var seen = new HashSet<string>(StringComparer.Ordinal);
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (!applies(cell) || cell.ReferenceNanosecondsPerRow <= 0f || !seen.Add(cell.GroupKey))
                continue;
            var ratio = cell.MedianNanosecondsPerRow / cell.ReferenceNanosecondsPerRow;
            if (ratio > ReferenceFactor)
                failures.Add(Describe(cell, "reference", ratio, ReferenceFactor));
        }

        return failures;
    }

    /// <summary>Fails the test when this bar has failures; the same check as <see cref="CollectMedianClassWithinTwiceReference"/>.</summary>
    internal static void AssertMedianClassWithinTwiceReference(List<ProofCell> cells, Func<ProofCell, bool> applies) => Fail(ReferenceBar, CollectMedianClassWithinTwiceReference(cells, applies));

    /// <summary>
    /// Bar (iii): along the parameter, each class's cost per row stays within twice a least-squares line through its own points (never below its smallest cost), and between
    /// neighbouring parameters it grows by at most twice the ratio of the parameters.
    /// </summary>
    internal static List<string> CollectLinearGrowth(List<ProofCell> cells)
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
        return failures;
    }

    /// <summary>Fails the test when this bar has failures; the same check as <see cref="CollectLinearGrowth"/>.</summary>
    internal static void AssertLinearGrowth(List<ProofCell> cells) => Fail(GrowthBar, CollectLinearGrowth(cells));

    /// <summary>
    /// Bar (iii) for first-true-offset: the median over its cells of every class is at most 1.25 times the all-false full scan at the same counts class and parameter. A cell that carries a
    /// full scan timed back to back with it is compared with that; any other cell with the all-false cell of the table. A single cell over the limit is not a failure of this bar; see
    /// <see cref="FullScanCellsOverTheLimit"/>.
    /// </summary>
    internal static List<string> CollectWithinFullScan(List<ProofCell> cells, Func<ProofCell, bool> applies)
    {
        var failures = new List<string>();
        var classes = new Dictionary<string, List<float>>(StringComparer.Ordinal);
        var first = new Dictionary<string, ProofCell>(StringComparer.Ordinal);
        foreach (var (cell, ratio) in FullScanRatios(cells, applies))
        {
            var key = string.Concat(cell.Operation, "|", cell.ClassName);
            if (!classes.TryGetValue(key, out var list))
            {
                list = [];
                classes.Add(key, list);
                first.Add(key, cell);
            }

            list.Add(ratio);
        }

        foreach (var pair in classes)
        {
            var median = ProofTiming.Median(pair.Value.ToArray());
            if (median > FullScanFactor)
            {
                failures.Add(string.Create(
                    CultureInfo.InvariantCulture,
                    $"{first[pair.Key].Operation} class {first[pair.Key].ClassName}: the median of {pair.Value.Count} cells is {median:F2} times the all-false full scan (limit {FullScanFactor:F2})"));
            }
        }

        return failures;
    }

    /// <summary>
    /// The cells that are over 1.25 times their all-false full scan, one line each in a stable format: operation, class, counts class, parameter and the ratio, tab-separated. Written to a side
    /// file for the comparison of two runs; it is not a failure of this test.
    /// </summary>
    internal static string FullScanCellsOverTheLimit(List<ProofCell> cells, Func<ProofCell, bool> applies)
    {
        var text = new StringBuilder("operation\tclass\tcounts\tparameter\tratio\n");
        foreach (var (cell, ratio) in FullScanRatios(cells, applies))
        {
            if (ratio > FullScanFactor)
                text.Append(CultureInfo.InvariantCulture, $"{cell.Operation}\t{cell.ClassName}\t{cell.Counts}\t{cell.Parameter}\t{ratio:F3}\n");
        }

        return text.ToString();
    }

    private static List<(ProofCell Cell, float Ratio)> FullScanRatios(List<ProofCell> cells, Func<ProofCell, bool> applies)
    {
        var ratios = new List<(ProofCell Cell, float Ratio)>();
        var scans = new Dictionary<string, float>(StringComparer.Ordinal);
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
            if (scan <= 0f && !scans.TryGetValue(cell.GroupKey, out scan))
                continue;
            ratios.Add((cell, cell.NanosecondsPerRow / scan));
        }

        return ratios;
    }

    /// <summary>Fails the test when this bar has failures; the same check as <see cref="CollectWithinFullScan"/>.</summary>
    internal static void AssertWithinFullScan(List<ProofCell> cells, Func<ProofCell, bool> applies) => Fail(FullScanBar, CollectWithinFullScan(cells, applies));

    /// <summary>Bar (iv) for the cells that carry a reference timed on their own class's data: they cost at most twice that reference.</summary>
    internal static List<string> CollectWithinTwiceSameClassReference(List<ProofCell> cells)
    {
        var failures = new List<string>();
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (cell.SameClassReferenceNanosecondsPerRow <= 0f)
                continue;
            var ratio = cell.NanosecondsPerRow / cell.SameClassReferenceNanosecondsPerRow;
            if (ratio > ReferenceFactor)
                failures.Add(Describe(cell, "reference on the same data", ratio, ReferenceFactor));
        }

        return failures;
    }

    /// <summary>Fails the test once with the failures of every bar that has any, or passes when no bar has.</summary>
    internal static void FailAll(List<(string Bar, List<string> Failures)> bars)
    {
        var message = new StringBuilder();
        var total = 0;
        for (var index = 0; index < bars.Count; index++)
        {
            var (bar, failures) = bars[index];
            if (failures.Count == 0)
                continue;
            total += failures.Count;
            message.Append(bar).Append(": ").Append(failures.Count.ToString(CultureInfo.InvariantCulture)).Append(" cell(s) over the limit:\n").AppendJoin('\n', failures).Append('\n');
        }

        Assert.True(total == 0, message.ToString());
    }

    /// <summary>Fails the test with the collected failures, or passes when there are none.</summary>
    internal static void Fail(string bar, List<string> failures) =>
        Assert.True(failures.Count == 0, bar + ": " + failures.Count.ToString(CultureInfo.InvariantCulture) + " cell(s) over the limit:\n" + string.Join('\n', failures));

    private static string Describe(ProofCell cell, string against, float ratio, float limit) =>
        string.Create(
            CultureInfo.InvariantCulture,
            $"{cell.Operation} class {cell.ClassName} counts {cell.Counts} parameter {cell.Parameter}: {cell.NanosecondsPerRow:F3} ns/row is {ratio:F2} times the {against} (limit {limit:F2})");

    private static void CheckSeries(string key, List<ProofCell> items, List<string> failures)
    {
        items.Sort((left, right) => left.Width.CompareTo(right.Width));
        var count = items.Count;
        if (count < 3)
            return;
        var widths = new float[count];
        var costs = new float[count];
        var floor = float.MaxValue;
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
    private static (float Intercept, float Slope) Fit(float[] widths, float[] costs)
    {
        var count = widths.Length;
        var meanWidth = 0f;
        var meanCost = 0f;
        for (var index = 0; index < count; index++)
        {
            meanWidth += widths[index] / count;
            meanCost += costs[index] / count;
        }

        var covariance = 0f;
        var variance = 0f;
        for (var index = 0; index < count; index++)
        {
            covariance += (widths[index] - meanWidth) * (costs[index] - meanCost);
            variance += (widths[index] - meanWidth) * (widths[index] - meanWidth);
        }

        var slope = variance > 0f ? covariance / variance : 0f;
        return (meanCost - slope * meanWidth, slope);
    }
}
