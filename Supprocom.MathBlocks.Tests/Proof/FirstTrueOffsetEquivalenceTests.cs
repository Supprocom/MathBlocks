using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The linear CPU path of sequence.first-true-offset@1 and its -valid sibling against the row by row scan of the earlier release, kept in <see cref="SequenceOracle"/>: every row's
/// value bits and validity over the proof class matrix and over random series, random availability, random counts (contiguity counts, counts with random drops, and counts that break
/// the one-step growth rule, which take the fallback) and random offset ranges, including ranges far outside the series.
/// </summary>
public sealed class FirstTrueOffsetEquivalenceTests
{
    private const int MatrixRows = 2500;
    private const int MaximumFailures = 20;

    private static readonly ProofParameter[] WideSpans =
    [
        new("[0,0]", 0d, 0d, 1d), new("[2,2]", 2d, 2d, 1d), new("[-1,-1]", -1d, -1d, 1d), new("[0,1000]", 0d, 1000d, 1001d), new("[-1000,1000]", -1000d, 1000d, 2001d),
        new("[-3,100000]", -3d, 100_000d, 100_004d), new("[5,2000000000]", 5d, 2_000_000_000d, 2_000_000_000d), new("[-2000000000,2000000000]", -2_000_000_000d, 2_000_000_000d, 4_000_000_001d),
        new("[2147483647,2147483647]", int.MaxValue, int.MaxValue, 1d), new("[-2147483647,-1]", -int.MaxValue, -1d, int.MaxValue), new("[-7,-2]", -7d, -2d, 6d), new("[3,9]", 3d, 9d, 7d)
    ];

    /// <summary>Verifies the class matrix at 2,500 rows over the safety spans and the wide spans, for all four counts classes.</summary>
    [Fact]
    public void TheLinearPathMatchesTheScanOverTheClassMatrix()
    {
        var sets = ProofSets.ForSequences(MatrixRows, includeReal: true, includeAllFalse: true);
        ProofParameter[] spans = [.. SequenceOps.SpanSafety, .. WideSpans];
        var failures = new List<string>();
        for (var setIndex = 0; setIndex < sets.Length; setIndex++)
        {
            var set = sets[setIndex];
            for (var kind = 0; kind < ProofCounts.SafetyKinds; kind++)
            {
                var counts = ProofCounts.Build(kind, MatrixRows, 7, 101);
                for (var index = 0; index < spans.Length; index++)
                    Compare(string.Concat(set.Name, "/", ProofCounts.Name(kind, 7, 101), "/", spans[index].Label), set.Predicate, set.Available, counts, spans[index], failures);
            }
        }

        ProofBar.Fail("Class matrix", failures);
    }

    /// <summary>Verifies 3,000 random series of random length with random counts and random offset ranges.</summary>
    [Fact]
    public void TheLinearPathMatchesTheScanOverRandomSeries()
    {
        var random = new Random(20261118);
        var failures = new List<string>();
        for (var round = 0; round < 3000 && failures.Count < MaximumFailures; round++)
        {
            var length = round % 10 == 0 ? random.Next(200, 1500) : random.Next(1, 40);
            var trueShare = random.Next(0, 4) switch { 0 => 0d, 1 => 0.02d, 2 => 0.3d, _ => 0.9d };
            var invalidShare = random.Next(0, 3) switch { 0 => 0d, 1 => 0.05d, _ => 0.4d };
            var predicate = new double[length];
            var available = new bool[length];
            for (var row = 0; row < length; row++)
            {
                predicate[row] = random.NextDouble() < trueShare ? (random.Next(3) == 0 ? -2.5d : 1d) : (random.Next(2) == 0 ? 0d : -0d);
                available[row] = random.NextDouble() >= invalidShare;
            }

            var counts = RandomCounts(random, length, round % 4);
            var spanLength = random.Next(0, 4) switch { 0 => 3, 1 => 12, 2 => 70, _ => 3000 };
            var start = random.Next(-spanLength, spanLength);
            var end = start + random.Next(0, spanLength);
            var label = string.Create(CultureInfo.InvariantCulture, $"round {round} n={length} counts class {round % 4} [{start},{end}]");
            Compare(label, predicate, available, counts, new ParameterPair(start, end), failures);
        }

        ProofBar.Fail("Random series", failures);
    }

    /// <summary>
    /// Verifies a count that is negative or not an integer makes the whole call invalid wherever it stands in the series (inside a block of four or in the tail), and that counts
    /// which are integers by value (negative zero, 1e15, 2^52 + 1) do not.
    /// </summary>
    [Fact]
    public void ABadCountInvalidatesTheCallAtEveryPosition()
    {
        var failures = new List<string>();
        double[] bad = [0.5d, -1d, -0.25d, 3.000000000000001d];
        double[] fine = [-0d, 1e15d, 4_503_599_627_370_497d];
        for (var length = 1; length <= 21; length++)
        {
            var predicate = new double[length];
            Array.Fill(predicate, 1d);
            var available = new bool[length];
            Array.Fill(available, true);
            for (var position = 0; position < length; position++)
            {
                for (var kind = 0; kind < bad.Length + fine.Length; kind++)
                {
                    var counts = new double[length];
                    counts[position] = kind < bad.Length ? bad[kind] : fine[kind - bad.Length];
                    var expectValid = kind >= bad.Length;
                    for (var sibling = 0; sibling < 2; sibling++)
                    {
                        var result = SequenceOps.Operation(SequenceOps.FirstTrue, sibling == 1).Evaluate(
                            SequenceOps.Inputs(SequenceOps.FirstTrue, sibling == 1, MathBlockValue.Vector(predicate), MathBlockValue.BooleanVector(available), MathBlockValue.Vector(counts), 0d, 1d));
                        if (result.IsValid != expectValid)
                            failures.Add(string.Create(CultureInfo.InvariantCulture, $"n={length} position {position} count {counts[position]:R}: IsValid {result.IsValid}, expected {expectValid}."));
                    }
                }
            }
        }

        ProofBar.Fail("Counts validation", failures);
    }

    /// <summary>
    /// Verifies every span with a start from -30 to 30 and an end up to 45 rows after it, over short series cut into segments of every small length (also with a first count above
    /// zero), with sparse, dense and unavailable predicate rows, so that spans start before the series and before a segment, and end inside, at and past the end of a segment.
    /// </summary>
    [Fact]
    public void NegativeStartsAndSpansAcrossASegmentEndMatchTheScan()
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
                var first = segmentIndex % 2 == 1 ? 3 : 0;
                for (var row = 0; row < length; row++)
                    counts[row] = row % segmentLengths[segmentIndex] == 0 && row > 0 ? 0d : (row == 0 ? first : counts[row - 1] + 1d);
                for (var shape = 0; shape < 6; shape++)
                {
                    var predicate = new double[length];
                    var available = new bool[length];
                    for (var row = 0; row < length; row++)
                    {
                        available[row] = shape < 2 || random.NextDouble() >= 0.15d;
                        predicate[row] = shape switch
                        {
                            0 => 0d,
                            1 => 1d,
                            2 => row == length - 2 ? 1d : -0d,
                            3 => random.NextDouble() < 0.1d ? 2.5d : 0d,
                            4 => random.NextDouble() < 0.5d ? -1d : 0d,
                            _ => row % 7 == 3 ? 1d : 0d
                        };
                    }

                    for (var start = -30; start <= 30 && failures.Count < MaximumFailures; start++)
                    {
                        for (var end = start; end <= start + 45 && failures.Count < MaximumFailures; end++)
                        {
                            var label = string.Create(CultureInfo.InvariantCulture, $"n={length} segments {segmentLengths[segmentIndex]} first {first} shape {shape} [{start},{end}]");
                            Compare(label, predicate, available, counts, new ParameterPair(start, end), failures);
                        }
                    }
                }
            }
        }

        ProofBar.Fail("Negative starts and segment ends", failures);
    }

    // Class 0: contiguity counts with random restarts. Class 1: counts that drop to a random smaller value (still growing by at most 1). Class 2: arbitrary counts, which break the
    // growth rule most of the time. Class 3: contiguity counts with one random jump upwards.
    private static double[] RandomCounts(Random random, int length, int kind)
    {
        var counts = new double[length];
        for (var row = 0; row < length; row++)
        {
            var previous = row == 0 ? 0d : counts[row - 1];
            counts[row] = kind switch
            {
                0 => row == 0 || random.NextDouble() < 0.1d ? 0d : previous + 1d,
                1 => row == 0 ? random.Next(0, 4) : Math.Max(0d, random.NextDouble() < 0.15d ? random.Next(0, (int)previous + 2) : previous + 1d),
                2 => random.Next(0, 12),
                _ => row == 0 ? 0d : (row == length / 2 && length > 4 ? previous + 3d : previous + 1d)
            };
        }

        return counts;
    }

    private static void Compare(string label, double[] predicate, bool[] available, double[] counts, ProofParameter parameter, List<string> failures) =>
        Compare(label, predicate, available, counts, new ParameterPair((long)parameter.First, (long)parameter.Second), failures);

    private static void Compare(string label, double[] predicate, bool[] available, double[] counts, ParameterPair range, List<string> failures)
    {
        var expected = SequenceOracle.Run(SequenceOps.FirstTrue, predicate, available, counts, range.Start, range.End);
        var series = MathBlockValue.Vector(predicate);
        var availability = MathBlockValue.BooleanVector(available);
        var countsValue = MathBlockValue.Vector(counts);
        var values = SequenceOps.Operation(SequenceOps.FirstTrue, false).Evaluate(SequenceOps.Inputs(SequenceOps.FirstTrue, false, series, availability, countsValue, range.Start, range.End));
        var flags = SequenceOps.Operation(SequenceOps.FirstTrue, true).Evaluate(SequenceOps.Inputs(SequenceOps.FirstTrue, true, series, availability, countsValue, range.Start, range.End));
        if (!values.IsValid || !flags.IsValid)
        {
            failures.Add(label + ": the call was invalid as a whole.");
            return;
        }

        var actualValues = values.AsVector().ToArray();
        var actualFlags = flags.AsBooleanVector().ToArray();
        for (var row = 0; row < predicate.Length && failures.Count < MaximumFailures; row++)
        {
            if (actualFlags[row] != expected.Valid[row] || BitConverter.DoubleToInt64Bits(actualValues[row]) != BitConverter.DoubleToInt64Bits(expected.Values[row]))
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: expected {expected.Values[row]:R}/{expected.Valid[row]}, actual {actualValues[row]:R}/{actualFlags[row]}"));
        }
    }

    private sealed record ParameterPair(long Start, long End);
}
