using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The per-row cost matrix of the logic blocks on the plain device route: every block on every input class of the proof matrix (typical, counts, extreme, near-overflow, subnormal,
/// invalid, domain edge, mixed, and the real market columns when they exist), timed with CUDA events as the median of seven launches after a warm-up launch. A vector block is timed in
/// nanoseconds per row at 262,144 and 1,048,576 rows. A scalar or Boolean block takes one value per dispatch, so it is timed in nanoseconds per dispatch over 2,048 dispatches of one class.
/// The scalar classes keep NaN and the infinities (such an operand is an invalid value); the vector classes replace them by zero, as the host does. The matrix goes to logic-blocks-cost.tsv.
/// boolean-vector.any and boolean-vector.all are whole-vector reducers with no window form.
/// </summary>
public sealed class LogicBlockCostTests
{
    private const int Dispatches = 2048;

    /// <summary>
    /// Verifies bars (i) and (ii): per block, the worst class (the mixed warp among them) costs at most twice the median class; and bar (iii): the time at 1,048,576 rows is at most five
    /// times the time at 262,144 rows for every vector block and class.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "Performance")]
    public void TheLogicBlocksCostTheSamePerRowOnEveryInputClass()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        if (ProofRealData.Get() is null)
            Console.WriteLine($"Real market class skipped: {ProofRealData.SkipReason}");
        var cells = new List<ProofCell>();
        var table = new List<string> { "identity\tclass\trows\tns_per_row" };
        using var device = new VectorBlockDevice();
        for (var identityIndex = 0; identityIndex < LogicBlocks.All.Length; identityIndex++)
        {
            var identity = LogicBlocks.All[identityIndex];
            if (LogicBlocks.IsScalarKind(identity))
            {
                Measure(device, identity, Dispatches, scalar: true, cells, table);
                continue;
            }

            for (var rowIndex = 0; rowIndex < VectorBlockCalls.TimingRows.Length; rowIndex++)
                Measure(device, identity, VectorBlockCalls.TimingRows[rowIndex], scalar: false, cells, table);
        }

        _ = ProofReport.WriteText("logic-blocks-cost.tsv", string.Join('\n', table) + "\n");
        ProofBar.Annotate(cells);
        var failures = ProofBar.CollectWorstClassWithinTwiceMedian(cells, _ => true);
        failures.AddRange(Growth(cells));
        ProofBar.Fail("Logic block cost matrix", failures);
    }

    private static void Measure(VectorBlockDevice device, string identity, int rows, bool scalar, List<ProofCell> cells, List<string> table)
    {
        var sets = ProofSets.ForRows(rows, includeReal: true);
        for (var setIndex = 0; setIndex < sets.Length; setIndex++)
        {
            var set = sets[setIndex];
            var inputs = scalar ? ScalarSteps(identity, set, rows) : [LogicBlocks.VectorInputs(identity, VectorBlockCalls.Clean(set.First), VectorBlockCalls.Clean(set.Second))];
            var steps = inputs.Length;
            var call = new VectorBlockCall(identity, "plain", "-", 1f, 0f, [.. Enumerable.Repeat(identity, steps)], steps);
            using var run = new VectorBlockRun(device, call, inputs);
            var nanoseconds = run.NanosecondsPerRow(rows);
            var operation = string.Create(CultureInfo.InvariantCulture, $"{identity} rows={rows}");
            cells.Add(new ProofCell(operation, set.Name, "-", "-", rows, nanoseconds, 0f, 0f));
            table.Add(string.Create(CultureInfo.InvariantCulture, $"{identity}\t{set.Name}\t{rows}\t{nanoseconds:F3}"));
        }
    }

    // One dispatch per row of the class: the operands are the class values at the row (the second operand's third value is the next row's).
    private static MathBlockValue[][] ScalarSteps(string identity, ProofSet set, int steps)
    {
        var inputs = new MathBlockValue[steps][];
        for (var step = 0; step < steps; step++)
            inputs[step] = LogicBlocks.ScalarInputs(identity, set.First[step], set.Second[step], set.Second[(step + 1) % steps]);
        return inputs;
    }

    // Bar (iii) for the vector blocks: four times the rows costs at most five times the launch time.
    private static List<string> Growth(List<ProofCell> cells)
    {
        var failures = new List<string>();
        var small = new Dictionary<string, float>(StringComparer.Ordinal);
        for (var index = 0; index < cells.Count; index++)
        {
            if (cells[index].Operation.EndsWith($"rows={VectorBlockCalls.TimingRows[0]}", StringComparison.Ordinal))
                small[cells[index].Operation[..^$"rows={VectorBlockCalls.TimingRows[0]}".Length] + "|" + cells[index].ClassName] = cells[index].NanosecondsPerRow * VectorBlockCalls.TimingRows[0];
        }

        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (!cell.Operation.EndsWith($"rows={VectorBlockCalls.TimingRows[1]}", StringComparison.Ordinal))
                continue;
            var key = cell.Operation[..^$"rows={VectorBlockCalls.TimingRows[1]}".Length] + "|" + cell.ClassName;
            if (!small.TryGetValue(key, out var before))
                continue;
            var ratio = cell.NanosecondsPerRow * VectorBlockCalls.TimingRows[1] / before;
            if (ratio > 5f)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"Bar (iii), growth with rows: {cell.Operation} class {cell.ClassName}: {ratio:F2} times the time at {VectorBlockCalls.TimingRows[0]} rows (limit 5.00)"));
        }

        return failures;
    }
}
