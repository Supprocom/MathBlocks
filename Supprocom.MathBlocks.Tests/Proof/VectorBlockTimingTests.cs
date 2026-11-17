using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The device speed proof of window.vector.standardize@1, vector.scale@1 and vector.subtract@1 on PatternResearcher's device route: every call (each window width and scale factor, each route)
/// on every input class and the real market columns at 262,144 and 1,048,576 rows, timed with CUDA events as the median of seven launches after a warm-up launch, in nanoseconds per row. The
/// full table goes to the test output and to vector-blocks-070.tsv. Bars (i), (ii) and (iii) are asserted here; bar (iv), the 0.6.1 regression bar, is the baseline console's compare step.
/// </summary>
public sealed class VectorBlockTimingTests
{
    private const double WorstClassFactor = 2d;
    private const double GrowthFactor = 5d;

    /// <summary>
    /// Verifies bar (i): per identity, route and parameter, the worst class costs at most twice the median class (every class, subnormal included); bar (ii): the mixed warp costs at most twice
    /// the median class; and bar (iii): the time at 1,048,576 rows is at most five times the time at 262,144 rows, for every call and class. All failures are listed; no bar is loosened.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "Performance")]
    public void VectorBlocksAreConsistentlyFastOnTheDeviceRoute()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        if (ProofRealData.Get() is null)
            Console.WriteLine(string.Create(CultureInfo.InvariantCulture, $"Real market class skipped: {ProofRealData.SkipReason}"));
        var measured = VectorBlockTable.Measure(VectorBlockCalls.All(includeLifted: true), VectorBlockCalls.TimingRows, Console.WriteLine);
        var table = VectorBlockTable.Render(measured);
        Console.WriteLine(table);
        _ = ProofReport.WriteText("vector-blocks-070.tsv", table);
        var cells = new List<ProofCell>();
        for (var index = 0; index < measured.Count; index++)
        {
            var cell = measured[index];
            var operation = string.Create(CultureInfo.InvariantCulture, $"{cell.Call.Name} rows={cell.Rows}");
            cells.Add(new ProofCell(operation, cell.ClassName, "-", cell.Call.Parameter, cell.Call.Width, cell.NanosecondsPerRow, 0d, 0d));
        }

        ProofBar.Annotate(cells);
        var failures = new List<string>();
        failures.AddRange(WorstClass(cells));
        failures.AddRange(Growth(measured));
        Assert.True(failures.Count == 0, string.Create(CultureInfo.InvariantCulture, $"{failures.Count} cell(s) over a bar:\n") + string.Join("\n", failures));
    }

    // Bars (i) and (ii): the median ratio of every class, with the mixed warp named on its own.
    private static List<string> WorstClass(List<ProofCell> cells)
    {
        var failures = new List<string>();
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (cell.MedianRatio <= WorstClassFactor)
                continue;
            var bar = string.Equals(cell.ClassName, nameof(ProofClass.Mixed), StringComparison.Ordinal) ? "Bar (ii), mixed warp" : "Bar (i), worst class";
            failures.Add(string.Create(CultureInfo.InvariantCulture, $"{bar}: {cell.Operation} parameter {cell.Parameter} class {cell.ClassName}: {cell.NanosecondsPerRow:F3} ns/row is {cell.MedianRatio:F2} times the median class (limit {WorstClassFactor:F2})"));
        }

        return failures;
    }

    // Bar (iii): the whole launch time grows by at most five times when the rows grow by four.
    private static List<string> Growth(List<VectorBlockCell> measured)
    {
        var failures = new List<string>();
        var small = new Dictionary<string, double>(StringComparer.Ordinal);
        for (var index = 0; index < measured.Count; index++)
        {
            if (measured[index].Rows == VectorBlockCalls.TimingRows[0])
                small[Key(measured[index])] = measured[index].NanosecondsPerRow * measured[index].Rows;
        }

        for (var index = 0; index < measured.Count; index++)
        {
            var cell = measured[index];
            if (cell.Rows != VectorBlockCalls.TimingRows[1] || !small.TryGetValue(Key(cell), out var before))
                continue;
            var ratio = cell.NanosecondsPerRow * cell.Rows / before;
            if (ratio > GrowthFactor)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"Bar (iii), growth with rows: {cell.Call.Name} parameter {cell.Call.Parameter} class {cell.ClassName}: T({cell.Rows}) is {ratio:F2} times T({VectorBlockCalls.TimingRows[0]}) (limit {GrowthFactor:F2})"));
        }

        return failures;
    }

    private static string Key(VectorBlockCell cell) => string.Concat(cell.Call.Name, "|", cell.Call.Parameter, "|", cell.ClassName);
}
