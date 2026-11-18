using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The sum-over-offsets and maximum-over-offsets operations and their -valid siblings against the independent evaluation of the design in <see cref="SequenceOracle"/>: every row's
/// value bits and validity over the proof class matrix, over random series (also with values near the largest double, whose running sums overflow), over counts cut into segments and
/// over arbitrary counts, and over spans that start before the series or a segment and end inside, at and past a segment's end.
/// </summary>
public sealed class OffsetValidityEquivalenceTests
{
    private const int MatrixRows = 2500;
    private const int MaximumFailures = 20;

    private static readonly string[] Names = ["sum-over-offsets", "maximum-over-offsets"];

    private static readonly ProofParameter[] WideSpans =
    [
        new("[0,0]", 0d, 0d, 1d), new("[2,2]", 2d, 2d, 1d), new("[-1,-1]", -1d, -1d, 1d), new("[0,1000]", 0d, 1000d, 1001d), new("[-1000,1000]", -1000d, 1000d, 2001d),
        new("[-3,100000]", -3d, 100_000d, 100_004d), new("[5,2000000000]", 5d, 2_000_000_000d, 2_000_000_000d), new("[-2000000000,2000000000]", -2_000_000_000d, 2_000_000_000d, 4_000_000_001d),
        new("[-7,-2]", -7d, -2d, 6d), new("[3,9]", 3d, 9d, 7d), new("[-63,0]", -63d, 0d, 64d), new("[0,255]", 0d, 255d, 256d)
    ];

    /// <summary>Verifies the class matrix at 2,500 rows over the safety spans and the wide spans, for all four counts classes.</summary>
    [Fact]
    public void TheValueAndValidFormsMatchTheDesignOverTheClassMatrix()
    {
        var sets = ProofSets.ForSequences(MatrixRows, includeReal: true, includeAllFalse: true);
        ProofParameter[] spans = [.. SequenceOps.SpanSafety, .. WideSpans];
        var failures = new List<string>();
        for (var nameIndex = 0; nameIndex < Names.Length; nameIndex++)
        {
            for (var setIndex = 0; setIndex < sets.Length; setIndex++)
            {
                var set = sets[setIndex];
                for (var kind = 0; kind < ProofCounts.SafetyKinds; kind++)
                {
                    var counts = ProofCounts.Build(kind, MatrixRows, 7, 101);
                    for (var index = 0; index < spans.Length && failures.Count < MaximumFailures; index++)
                        Compare(string.Concat(Names[nameIndex], "/", set.Name, "/", ProofCounts.Name(kind, 7, 101), "/", spans[index].Label), Names[nameIndex], set.First, set.Available, counts, spans[index].First, spans[index].Second, failures);
                }
            }
        }

        ProofBar.Fail("Class matrix", failures);
    }

    /// <summary>Verifies random series with random availability, magnitudes up to the largest double, random counts (segmented or arbitrary) and random spans.</summary>
    [Fact]
    public void TheValueAndValidFormsMatchTheDesignOverRandomSeries()
    {
        var random = new Random(20261118);
        var failures = new List<string>();
        for (var round = 0; round < 2400 && failures.Count < MaximumFailures; round++)
        {
            var length = round % 10 == 0 ? random.Next(200, 1200) : random.Next(1, 40);
            var scale = random.Next(0, 4) switch { 0 => 1d, 1 => 1e5d, 2 => 1e300d, _ => 1.7e308d };
            var invalidShare = random.Next(0, 3) switch { 0 => 0d, 1 => 0.03d, _ => 0.4d };
            var series = new double[length];
            var available = new bool[length];
            for (var row = 0; row < length; row++)
            {
                series[row] = (random.NextDouble() * 2d - 1d) * scale;
                available[row] = random.NextDouble() >= invalidShare;
            }

            var counts = RandomCounts(random, length, round % 3);
            var spanLength = random.Next(0, 4) switch { 0 => 3, 1 => 12, 2 => 70, _ => 3000 };
            var start = random.Next(-spanLength, spanLength);
            var end = start + random.Next(0, spanLength);
            var label = string.Create(CultureInfo.InvariantCulture, $"round {round} n={length} scale {scale:R} counts class {round % 3} [{start},{end}]");
            for (var nameIndex = 0; nameIndex < Names.Length; nameIndex++)
                Compare(string.Concat(Names[nameIndex], " ", label), Names[nameIndex], series, available, counts, start, end, failures);
        }

        ProofBar.Fail("Random series", failures);
    }

    /// <summary>Verifies every span with a start from -30 to 30 over short series cut into segments of every small length, with a mix of unavailable rows and large values.</summary>
    [Fact]
    public void NegativeStartsAndSpansAcrossASegmentEndMatchTheDesign()
    {
        var random = new Random(18112026);
        var failures = new List<string>();
        int[] lengths = [3, 9, 24, 40];
        int[] segmentLengths = [1, 2, 3, 5, 11, 1000];
        for (var lengthIndex = 0; lengthIndex < lengths.Length; lengthIndex++)
        {
            var length = lengths[lengthIndex];
            for (var segmentIndex = 0; segmentIndex < segmentLengths.Length; segmentIndex++)
            {
                var counts = new double[length];
                for (var row = 0; row < length; row++)
                    counts[row] = row % segmentLengths[segmentIndex] == 0 ? 0d : counts[row - 1] + 1d;
                for (var shape = 0; shape < 4; shape++)
                {
                    var series = new double[length];
                    var available = new bool[length];
                    for (var row = 0; row < length; row++)
                    {
                        available[row] = shape == 0 || random.NextDouble() >= 0.1d;
                        series[row] = shape == 3 ? (random.Next(2) == 0 ? 1.5e308d : -1.7e308d) : (random.NextDouble() - 0.4d) * 100d;
                    }

                    for (var start = -30; start <= 30 && failures.Count < MaximumFailures; start++)
                    {
                        for (var end = start; end <= start + 45 && failures.Count < MaximumFailures; end += 3)
                        {
                            for (var nameIndex = 0; nameIndex < Names.Length; nameIndex++)
                                Compare(string.Create(CultureInfo.InvariantCulture, $"{Names[nameIndex]} n={length} segments {segmentLengths[segmentIndex]} shape {shape} [{start},{end}]"), Names[nameIndex], series, available, counts, start, end, failures);
                        }
                    }
                }
            }
        }

        ProofBar.Fail("Negative starts and segment ends", failures);
    }

    /// <summary>
    /// Verifies the overflow decision of the sum: alternating plus and minus 1.7e308, a single huge value at every position of a span of 256, and partial sums that land a few units in
    /// the last place below, at and above the point where a sum rounds to infinity, with the huge values cancelled again later in the span.
    /// </summary>
    [Fact]
    public void RunningSumsAtTheLargestDoubleMatchTheDesign()
    {
        var failures = new List<string>();
        ProofParameter[] spans = [.. SequenceOps.SpanSafety, new("[0,255]", 0d, 255d, 256d), new("[-7,3]", -7d, 3d, 11d), new("[0,63]", 0d, 63d, 64d), new("[-63,0]", -63d, 0d, 64d), new("[1,2]", 1d, 2d, 2d)];
        var decidedBefore = ReadCounter("OverflowDecidedRows");
        var alternating = new double[600];
        for (var row = 0; row < alternating.Length; row++)
            alternating[row] = row % 2 == 0 ? 1.7e308d : -1.7e308d;
        CompareSpans("alternating", alternating, Contiguous(alternating.Length, 0), spans, failures);

        var random = new Random(7);
        foreach (var huge in new[] { 1.7976931348623157e308d, -1.7976931348623157e308d, 1e308d, 8.98846567431158e307d })
        {
            for (var position = 0; position < 300 && failures.Count < MaximumFailures; position++)
            {
                var series = new double[300];
                for (var row = 0; row < series.Length; row++)
                    series[row] = (random.NextDouble() - 0.5d) * 1e3d;
                series[position] = huge;
                CompareSpans(string.Create(CultureInfo.InvariantCulture, $"single {huge:R} at {position}"), series, Contiguous(series.Length, 0), spans, failures);
            }
        }

        var half = Math.Pow(2d, 1023d);
        var tie = half - Math.Pow(2d, 970d);
        long tieBits = BitConverter.DoubleToInt64Bits(tie);
        for (var step = -6; step <= 6 && failures.Count < MaximumFailures; step++)
        {
            var second = BitConverter.Int64BitsToDouble(tieBits + step);
            for (var shape = 0; shape < 4; shape++)
            {
                var series = new double[64];
                for (var row = 0; row < series.Length; row += 8)
                {
                    var sign = shape % 2 == 0 ? 1d : -1d;
                    series[row] = sign * half;
                    series[row + 1] = sign * second;
                    series[row + 2] = shape < 2 ? -sign * half : 0.25d;
                    series[row + 3] = shape < 2 ? -sign * second : 0d;
                    series[row + 4] = 3d;
                    series[row + 5] = sign * 1.7976931348623157e308d;
                    series[row + 6] = shape == 3 ? sign * Math.Pow(2d, 970d) : 0d;
                    series[row + 7] = -0d;
                }

                CompareSpans(string.Create(CultureInfo.InvariantCulture, $"near the limit step {step} shape {shape}"), series, Contiguous(series.Length, shape), spans, failures);
            }
        }

        Assert.True(ReadCounter("OverflowDecidedRows") > decidedBefore, "No row was decided by the prefix sums.");
        ProofBar.Fail("Running sums at the largest double", failures);
    }

    private static long ReadCounter(string name) =>
        (long)typeof(MathBlockVectorMath).GetField(name, System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Static)!.GetValue(null)!;

    // Contiguity counts that restart every 40 rows (kind 0), or never (kind 1), or every 5 rows (kind 2), or every 3 rows (kind 3).
    private static double[] Contiguous(int length, int kind)
    {
        var period = kind switch { 0 => 40, 1 => int.MaxValue, 2 => 5, _ => 3 };
        var counts = new double[length];
        for (var row = 0; row < length; row++)
            counts[row] = row % period == 0 ? 0d : counts[row - 1] + 1d;
        return counts;
    }

    private static void CompareSpans(string label, double[] series, double[] counts, ProofParameter[] spans, List<string> failures)
    {
        var available = new bool[series.Length];
        Array.Fill(available, true);
        for (var index = 0; index < spans.Length && failures.Count < MaximumFailures; index++)
        {
            for (var nameIndex = 0; nameIndex < Names.Length; nameIndex++)
                Compare(string.Concat(Names[nameIndex], " ", label, " ", spans[index].Label), Names[nameIndex], series, available, counts, spans[index].First, spans[index].Second, failures);
        }
    }

    // Class 0: contiguity counts with random restarts. Class 1: contiguity counts with a first count above zero. Class 2: arbitrary counts.
    private static double[] RandomCounts(Random random, int length, int kind)
    {
        var counts = new double[length];
        for (var row = 0; row < length; row++)
        {
            var previous = row == 0 ? 0d : counts[row - 1];
            counts[row] = kind switch
            {
                0 => row == 0 || random.NextDouble() < 0.1d ? 0d : previous + 1d,
                1 => row == 0 ? random.Next(1, 5) : (random.NextDouble() < 0.1d ? 0d : previous + 1d),
                _ => random.Next(0, 12)
            };
        }

        return counts;
    }

    private static void Compare(string label, string name, double[] series, bool[] available, double[] counts, double first, double second, List<string> failures)
    {
        var expected = SequenceOracle.Run(name, series, available, counts, (long)first, (long)second);
        var seriesValue = MathBlockValue.Vector(series);
        var availability = MathBlockValue.BooleanVector(available);
        var countsValue = MathBlockValue.Vector(counts);
        var values = SequenceOps.Operation(name, false).Evaluate(SequenceOps.Inputs(name, false, seriesValue, availability, countsValue, first, second));
        var flags = SequenceOps.Operation(name, true).Evaluate(SequenceOps.Inputs(name, true, seriesValue, availability, countsValue, first, second));
        if (!values.IsValid || !flags.IsValid)
        {
            failures.Add(label + ": the call was invalid as a whole.");
            return;
        }

        var actualValues = values.AsVector().ToArray();
        var actualFlags = flags.AsBooleanVector().ToArray();
        for (var row = 0; row < series.Length && failures.Count < MaximumFailures; row++)
        {
            if (actualFlags[row] != expected.Valid[row] || BitConverter.DoubleToInt64Bits(actualValues[row]) != BitConverter.DoubleToInt64Bits(expected.Values[row]))
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: expected {expected.Values[row]:R}/{expected.Valid[row]}, actual {actualValues[row]:R}/{actualFlags[row]}"));
        }
    }
}
