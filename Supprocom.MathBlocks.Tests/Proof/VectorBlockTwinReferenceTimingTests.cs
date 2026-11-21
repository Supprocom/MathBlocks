using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The device speed proof of PatternResearcher's lifted route for vector.scale@1 and vector.subtract@1 against the proven per-row elementwise binary operation (Overwatch ruling E): the twin's full
/// cost (the elementwise form with the fill, then its validity sibling) is timed next to the same two dispatches with the operand supplied as a column, which is multiply with a constant
/// column of the scale factor for scale and subtract of the second column for subtract. Both run on the same input class and the same row count, back to back, as the median of seven CUDA-event launches.
/// </summary>
public sealed class VectorBlockTwinReferenceTimingTests
{
    private const float GrowthFactor = 5f;
    private const string TableName = "vector-twin-reference.tsv";
    private const string TableHeader = "identity\tclass\tparameter\trows\ttwin_ns_per_row\treference_ns_per_row\tratio";

    /// <summary>
    /// Verifies bar (i): per identity and parameter, the worst class of the twin costs at most twice the median class; bar (ii): the mixed warp costs at most twice the median class; bar (iii): the
    /// time at 1,048,576 rows is at most five times the time at 262,144 rows; and bar (iv): the twin's full cost is at most twice the per-row elementwise operation on the same class. Every bar is
    /// evaluated and the test fails once with all of the failures.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "Performance")]
    public void LiftedTwinsAreConsistentlyFastAndWithinTwiceThePerRowElementwiseOperation()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        if (ProofRealData.Get() is null)
            Console.WriteLine($"Real market class skipped: {ProofRealData.SkipReason}");
        var measured = Measure(LiftedCalls());
        var table = Render(measured);
        Console.WriteLine(table);
        _ = ProofReport.WriteText(TableName, table);
        var cells = new List<ProofCell>();
        for (var index = 0; index < measured.Count; index++)
        {
            var item = measured[index];
            var operation = string.Create(CultureInfo.InvariantCulture, $"{item.Call.Name} rows={item.Rows}");
            cells.Add(new ProofCell(operation, item.ClassName, "-", item.Call.Parameter, item.Call.Width, item.TwinNanosecondsPerRow, 0f, 0f)
            {
                SameClassReferenceNanosecondsPerRow = item.ReferenceNanosecondsPerRow
            });
        }

        ProofBar.Annotate(cells);
        List<(string Bar, List<string> Failures)> bars =
        [
            (ProofBar.WorstClassBar, ProofBar.CollectWorstClassWithinTwiceMedian(cells, cell => !IsMixed(cell))),
            ("Bar (ii), mixed warp against the median class", ProofBar.CollectWorstClassWithinTwiceMedian(cells, IsMixed)),
            ("Bar (iii), growth with rows", Growth(measured)),
            ("Bar (iv), twin's full cost against the per-row elementwise operation on the same class (ruling E)", ProofBar.CollectWithinTwiceSameClassReference(cells))
        ];
        ProofBar.FailAll(bars);
    }

    private static bool IsMixed(ProofCell cell) => string.Equals(cell.ClassName, nameof(ProofClass.Mixed), StringComparison.Ordinal);

    // The lifted calls only: vector.subtract@1 and vector.scale@1 with each scale factor.
    private static List<VectorBlockCall> LiftedCalls()
    {
        var lifted = new List<VectorBlockCall>();
        var all = VectorBlockCalls.All(includeLifted: true);
        for (var index = 0; index < all.Count; index++)
        {
            if (all[index].IsLifted)
                lifted.Add(all[index]);
        }

        return lifted;
    }

    // Measures the twin and the reference of every call on every class at every row count, back to back on the same operands.
    private static List<Measurement> Measure(List<VectorBlockCall> calls)
    {
        using var device = new VectorBlockDevice();
        var measured = new List<Measurement>();
        for (var rowIndex = 0; rowIndex < VectorBlockCalls.TimingRows.Length; rowIndex++)
        {
            var rows = VectorBlockCalls.TimingRows[rowIndex];
            var sets = ProofSets.ForRows(rows, includeReal: true);
            for (var callIndex = 0; callIndex < calls.Count; callIndex++)
            {
                var call = calls[callIndex];
                var constant = new float[rows];
                Array.Fill(constant, call.Constant);
                for (var setIndex = 0; setIndex < sets.Length; setIndex++)
                {
                    var first = VectorBlockCalls.Clean(sets[setIndex].First);
                    var second = VectorBlockCalls.Clean(sets[setIndex].Second);
                    using var twin = device.Prepare(call, first, second);
                    using var reference = new VectorBlockRun(device, call, ReferenceInputs(first, string.Equals(call.Identity, VectorBlockCalls.Scale, StringComparison.Ordinal) ? constant : second));
                    var twinNanoseconds = twin.NanosecondsPerRow(rows);
                    var referenceNanoseconds = reference.NanosecondsPerRow(rows);
                    var item = new Measurement(call, sets[setIndex].Name, rows, twinNanoseconds, referenceNanoseconds);
                    measured.Add(item);
                    Console.WriteLine(Line(item));
                }
            }
        }

        return measured;
    }

    // The per-row elementwise binary operation with the operand as a column: the form with the fill, then its validity sibling.
    private static MathBlockValue[][] ReferenceInputs(float[] first, float[] column) =>
    [
        [MathBlockValue.Vector(first, MathBlockUnit.Dimensionless), MathBlockValue.Vector(column, MathBlockUnit.Dimensionless), MathBlockValue.Scalar(VectorBlockCalls.Fill)],
        [MathBlockValue.Vector(first, MathBlockUnit.Dimensionless), MathBlockValue.Vector(column, MathBlockUnit.Dimensionless)]
    ];

    // Bar (iii): the whole launch time of the twin grows by at most five times when the rows grow by four.
    private static List<string> Growth(List<Measurement> measured)
    {
        var failures = new List<string>();
        var small = new Dictionary<string, float>(StringComparer.Ordinal);
        for (var index = 0; index < measured.Count; index++)
        {
            if (measured[index].Rows == VectorBlockCalls.TimingRows[0])
                small[Key(measured[index])] = measured[index].TwinNanosecondsPerRow * measured[index].Rows;
        }

        for (var index = 0; index < measured.Count; index++)
        {
            var item = measured[index];
            if (item.Rows != VectorBlockCalls.TimingRows[1] || !small.TryGetValue(Key(item), out var before))
                continue;
            var ratio = item.TwinNanosecondsPerRow * item.Rows / before;
            if (ratio > GrowthFactor)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{item.Call.Name} parameter {item.Call.Parameter} class {item.ClassName}: T({item.Rows}) is {ratio:F2} times T({VectorBlockCalls.TimingRows[0]}) (limit {GrowthFactor:F2})"));
        }

        return failures;
    }

    private static string Key(Measurement item) => string.Concat(item.Call.Name, "|", item.Call.Parameter, "|", item.ClassName);

    private static string Render(List<Measurement> measured)
    {
        var text = new StringBuilder(TableHeader).Append('\n');
        for (var index = 0; index < measured.Count; index++)
            text.Append(Line(measured[index])).Append('\n');
        return text.ToString();
    }

    private static string Line(Measurement item) =>
        string.Create(
            CultureInfo.InvariantCulture,
            $"{item.Call.Identity}\t{item.ClassName}\t{item.Call.Parameter}\t{item.Rows}\t{item.TwinNanosecondsPerRow:F3}\t{item.ReferenceNanosecondsPerRow:F3}\t{item.TwinNanosecondsPerRow / item.ReferenceNanosecondsPerRow:F3}");

    private sealed record Measurement(VectorBlockCall Call, string ClassName, int Rows, float TwinNanosecondsPerRow, float ReferenceNanosecondsPerRow);
}
