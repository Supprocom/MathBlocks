using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The speed proof of the six new sequence operations on CoreCLR over 100,000 rows: every input class (the real market columns when present) against three counts classes (all
/// contiguous, a gap every 10 rows, series starts every 1000 rows) across PatternResearcher's parameter range, as the median of five evaluations after a warm-up, in nanoseconds
/// per row. A -valid sibling is timed on the Typical, Mixed, Invalid and AllFalse classes only. The numbers go to l3-timing-&lt;group&gt;.tsv. Each cell is the median of 15 timed evaluations
/// (see <see cref="ProofTiming"/> for the evaluations that count).
/// </summary>
public sealed class SequenceTimingTests
{
    private const int Rows = 100_000;
    private const int GapPeriod = 10;
    private const int SeriesPeriod = 1000;

    // The number of timed evaluations behind every cell of the L3 tables (after one warm-up).
    private const int Samples = 15;
    private const string SumOverOffsets = "sum-over-offsets";
    private const string MixedClass = nameof(ProofClass.Mixed);

    private static readonly string[] SiblingClasses = [nameof(ProofClass.Typical), nameof(ProofClass.Mixed), nameof(ProofClass.Invalid), nameof(ProofClass.AllFalse)];

    /// <summary>Times lead and lag against vector.gather@1 and checks bars (i), (iii) and (iv).</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void LeadAndLagAreConsistentlyFastAndWithinTwiceGather() => Measure("shift", ["lead", SequenceOps.Lag], SequenceOps.ShiftTiming);

    /// <summary>Times first-true-offset against sequence.rolling-sum@1 and checks bars (iii) and (iv), with the full-scan bound in place of bar (i).</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void FirstTrueOffsetIsWithinAQuarterOfItsFullScanAndTwiceRollingSum() => Measure("first-true", [SequenceOps.FirstTrue], SequenceOps.SpanTiming);

    /// <summary>Times sum-over-offsets and maximum-over-offsets against sequence.rolling-sum@1 and sequence.rolling-maximum@1 and checks bars (i), (iii) and (iv).</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void SumAndMaximumOverOffsetsAreConsistentlyFastAndWithinTwiceRolling() => Measure("offsets", ["sum-over-offsets", "maximum-over-offsets"], SequenceOps.SpanTiming);

    /// <summary>Times the prefix difference against vector.cumulative-sum@1 and checks bars (i), (iii) and (iv).</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void PrefixDifferenceIsConsistentlyFastAndWithinTwiceCumulativeSum() => Measure("prefix", ["prefix-difference-over-offsets"], SequenceOps.SpanTiming);

    private static void Measure(string table, string[] names, ProofParameter[] parameters)
    {
        var firstTrue = Array.IndexOf(names, SequenceOps.FirstTrue) >= 0;
        var sets = ProofSets.ForSequences(Rows, includeReal: true, includeAllFalse: firstTrue);
        if (ProofRealData.Get() is null)
            Console.WriteLine($"Real market class skipped: {ProofRealData.SkipReason}");
        var counts = new MathBlockValue[ProofCounts.TimingKinds];
        for (var kind = 0; kind < counts.Length; kind++)
            counts[kind] = MathBlockValue.Vector(ProofCounts.Build(kind, Rows, GapPeriod, SeriesPeriod));
        var cells = new List<ProofCell>();
        var bands = new System.Text.StringBuilder("operation\tclass\tcounts\tparameter\trows_decided_by_prefix_sums\trows_in_the_band_added_in_order\n");
        for (var nameIndex = 0; nameIndex < names.Length; nameIndex++)
        {
            for (var sibling = 0; sibling < 2; sibling++)
                MeasureOperation(names[nameIndex], sibling == 1, sets, counts, parameters, cells, bands);
        }

        ProofBar.Annotate(cells);
        _ = ProofReport.WriteText(string.Concat("l3-timing-", table, ".tsv"), ProofBar.Render(cells, Samples));
        if (string.Equals(table, "offsets", StringComparison.Ordinal))
            _ = ProofReport.WriteText("l3-band-offsets.tsv", bands.ToString());
        // Every bar is evaluated, and the test fails once with the failures of all of them.
        List<(string Bar, List<string> Failures)> bars =
        [
            (ProofBar.WorstClassBar, ProofBar.CollectWorstClassWithinTwiceMedian(cells, cell => !cell.Operation.Contains(SequenceOps.FirstTrue, StringComparison.Ordinal) && !IsMixedSumValid(cell))),
            (ProofBar.GrowthBar, ProofBar.CollectLinearGrowth(cells)),
            (ProofBar.ReferenceBar, ProofBar.CollectMedianClassWithinTwiceReference(cells, cell => !IsWideFixedOrderSum(cell)))
        ];
        if (cells.Exists(cell => cell.SameClassReferenceNanosecondsPerRow > 0f))
            bars.Add((ProofBar.SameClassBar, ProofBar.CollectWithinTwiceSameClassReference(cells)));
        if (firstTrue)
        {
            bars.Add((ProofBar.FullScanBar, ProofBar.CollectWithinFullScan(cells, _ => true)));
            _ = ProofReport.WriteText("l3-fullscan-cells.tsv", ProofBar.FullScanCellsOverTheLimit(cells, _ => true));
        }
        ProofBar.FailAll(bars);
    }

    // Every cell is the median of Samples timed evaluations, timed back to back with its comparison cells: first its reference (the main-era operation), then, for first-true-offset,
    // the all-false full scan at the same counts class and parameter, then the cell itself, so that the three see the same load. One measurement per cell is the result.
    private static void MeasureOperation(
        string name,
        bool sibling,
        ProofSet[] sets,
        MathBlockValue[] counts,
        ProofParameter[] parameters,
        List<ProofCell> cells,
        System.Text.StringBuilder bands)
    {
        var operation = SequenceOps.Operation(name, sibling);
        var typical = sets[0].First;
        var firstTrue = string.Equals(name, SequenceOps.FirstTrue, StringComparison.Ordinal);
        var allFalse = Array.Find(sets, set => string.Equals(set.Name, ProofBar.AllFalse, StringComparison.Ordinal));
        for (var setIndex = 0; setIndex < sets.Length; setIndex++)
        {
            var set = sets[setIndex];
            if (sibling && Array.IndexOf(SiblingClasses, set.Name) < 0)
                continue;
            var series = MathBlockValue.Vector(SequenceOps.Series(name, set));
            var availability = MathBlockValue.BooleanVector(set.Available);
            var scanSeries = firstTrue && allFalse is not null ? MathBlockValue.Vector(SequenceOps.Series(name, allFalse)) : series;
            var scanAvailability = firstTrue && allFalse is not null ? MathBlockValue.BooleanVector(allFalse.Available) : availability;
            var scanned = firstTrue && allFalse is not null && !ReferenceEquals(set, allFalse);
            for (var kind = 0; kind < counts.Length; kind++)
            {
                for (var parameterIndex = 0; parameterIndex < parameters.Length; parameterIndex++)
                {
                    var parameter = parameters[parameterIndex];
                    var inputs = SequenceOps.Inputs(name, sibling, series, availability, counts[kind], parameter.First, parameter.Second);
                    var reference = SequenceReference.Measure(name, parameter, typical, Samples);
                    var scan = 0f;
                    if (scanned)
                        scan = TimeOperation(operation, SequenceOps.Inputs(name, sibling, scanSeries, scanAvailability, counts[kind], parameter.First, parameter.Second), set.Name, kind, parameter);
                    var sameClass = sibling && string.Equals(name, SumOverOffsets, StringComparison.Ordinal) && string.Equals(set.Name, MixedClass, StringComparison.Ordinal)
                        ? SequenceReference.Measure(name, parameter, set.First, Samples)
                        : 0f;
                    var nanoseconds = TimeOperation(operation, inputs, set.Name, kind, parameter);
                    if (sibling && string.Equals(name, "sum-over-offsets", StringComparison.Ordinal))
                        RecordBand(bands, operation, inputs, set.Name, ProofCounts.Name(kind, GapPeriod, SeriesPeriod), parameter.Label);
                    cells.Add(new ProofCell(operation.Identifier, set.Name, ProofCounts.Name(kind, GapPeriod, SeriesPeriod), parameter.Label, parameter.Width, nanoseconds, reference, 0f) { FullScanNanosecondsPerRow = scan, SameClassReferenceNanosecondsPerRow = sameClass });
                }
            }
        }
    }

    // sum-over-offsets-valid on the Mixed class (values near the largest double, whose running sums can overflow) is judged against the rolling sum timed on the same data, and is not
    // part of bar (i); this is the one class and form that Overwatch ruled so (16 and 18 Nov).
    private static bool IsMixedSumValid(ProofCell cell) =>
        string.Equals(cell.ClassName, MixedClass, StringComparison.Ordinal) && cell.Operation.EndsWith(string.Concat(SumOverOffsets, "-valid"), StringComparison.Ordinal);

    // sum-over-offsets on a span wider than SequenceOps.FixedOrderSumSpanLimit is timed and written to the table, and bar (iii) holds its growth to a line, but it is not held to
    // twice the rolling sum: the order of its additions is its definition, and the rolling sum does not keep one. Its -valid sibling is held to the bar at every width.
    private static bool IsWideFixedOrderSum(ProofCell cell) =>
        cell.Width > SequenceOps.FixedOrderSumSpanLimit && cell.Operation.EndsWith(SumOverOffsets, StringComparison.Ordinal);

    private static float TimeOperation(MathBlockOperation operation, MathBlockValue[] inputs, string className, int kind, ProofParameter parameter)
    {
        var valid = false;
        var nanoseconds = ProofTiming.NanosecondsPerRow(
            () =>
            {
                valid = operation.Evaluate(inputs).IsValid;
            },
            Rows,
            Samples);
        Assert.True(valid, string.Create(CultureInfo.InvariantCulture, $"{operation.Identity} class {className} counts {kind} parameter {parameter.Label} was invalid as a whole."));
        return nanoseconds;
    }

    // One extra, untimed evaluation: how many rows the prefix sums decided and how many fell in the thin band and were added in order.
    private static void RecordBand(System.Text.StringBuilder bands, MathBlockOperation operation, MathBlockValue[] inputs, string className, string counts, string parameter)
    {
        var decidedBefore = ReadCounter("OverflowDecidedRows");
        var bandBefore = ReadCounter("OverflowBandRows");
        _ = operation.Evaluate(inputs);
        bands.Append(string.Create(CultureInfo.InvariantCulture, $"{operation.Identifier}\t{className}\t{counts}\t{parameter}\t{ReadCounter("OverflowDecidedRows") - decidedBefore}\t{ReadCounter("OverflowBandRows") - bandBefore}\n"));
    }

    private static long ReadCounter(string name) =>
        (long)typeof(MathBlockVectorMath).GetField(name, System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static)!.GetValue(null)!;
}
