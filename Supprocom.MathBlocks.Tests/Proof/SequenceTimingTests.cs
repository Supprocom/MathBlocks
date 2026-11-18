using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The speed proof of the six new sequence operations on CoreCLR over 100,000 rows: every input class (the real market columns when present) against three counts classes (all
/// contiguous, a gap every 10 rows, series starts every 1000 rows) across PatternResearcher's parameter range, as the median of five evaluations after a warm-up, in nanoseconds
/// per row. A -valid sibling is timed on the Typical, Mixed, Invalid and AllFalse classes only. The numbers go to l3-timing-&lt;group&gt;.tsv.
/// </summary>
public sealed class SequenceTimingTests
{
    private const int Rows = 100_000;
    private const int GapPeriod = 10;
    private const int SeriesPeriod = 1000;

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
        var references = new Dictionary<string, double>(StringComparer.Ordinal);
        var cells = new List<ProofCell>();
        for (var nameIndex = 0; nameIndex < names.Length; nameIndex++)
        {
            for (var sibling = 0; sibling < 2; sibling++)
                MeasureOperation(names[nameIndex], sibling == 1, sets, counts, parameters, references, cells);
        }

        ProofBar.Annotate(cells);
        _ = ProofReport.WriteText(string.Concat("l3-timing-", table, ".tsv"), ProofBar.Render(cells));
        ProofBar.AssertWorstClassWithinTwiceMedian(cells, cell => !cell.Operation.Contains(SequenceOps.FirstTrue, StringComparison.Ordinal));
        ProofBar.AssertLinearGrowth(cells);
        ProofBar.AssertMedianClassWithinTwiceReference(cells, _ => true);
        if (firstTrue)
            ProofBar.AssertWithinFullScan(cells, _ => true);
    }

    private static void MeasureOperation(
        string name,
        bool sibling,
        ProofSet[] sets,
        MathBlockValue[] counts,
        ProofParameter[] parameters,
        Dictionary<string, double> references,
        List<ProofCell> cells)
    {
        var operation = SequenceOps.Operation(name, sibling);
        var typical = sets[0].First;
        for (var setIndex = 0; setIndex < sets.Length; setIndex++)
        {
            var set = sets[setIndex];
            if (sibling && Array.IndexOf(SiblingClasses, set.Name) < 0)
                continue;
            var series = MathBlockValue.Vector(SequenceOps.Series(name, set));
            var availability = MathBlockValue.BooleanVector(set.Available);
            for (var kind = 0; kind < counts.Length; kind++)
            {
                for (var parameterIndex = 0; parameterIndex < parameters.Length; parameterIndex++)
                {
                    var parameter = parameters[parameterIndex];
                    var inputs = SequenceOps.Inputs(name, sibling, series, availability, counts[kind], parameter.First, parameter.Second);
                    var reference = SequenceReference.Nanoseconds(name, parameter, typical, references);
                    var valid = false;
                    var nanoseconds = ProofTiming.NanosecondsPerRow(
                        () =>
                        {
                            valid = operation.Evaluate(inputs).IsValid;
                        },
                        Rows);
                    Assert.True(valid, string.Create(CultureInfo.InvariantCulture, $"{operation.Identity} class {set.Name} counts {kind} parameter {parameter.Label} was invalid as a whole."));
                    cells.Add(new ProofCell(operation.Identifier, set.Name, ProofCounts.Name(kind, GapPeriod, SeriesPeriod), parameter.Label, parameter.Width, nanoseconds, reference, 0d));
                }
            }
        }
    }
}
