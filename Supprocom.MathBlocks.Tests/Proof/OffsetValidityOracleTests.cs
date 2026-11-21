using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The validity of sequence.sum-over-offsets-valid@1 on CoreCLR against the plain row-by-row scan and against the earlier prefix-sum path, over the proof classes (Mixed especially),
/// near-overflow mixes and random series, for narrow spans (added in vector lanes) and wide ones (prefix sums), contiguous and gapped counts.
/// </summary>
public sealed class OffsetValidityOracleTests
{
    private const int Rows = 1500;
    private const int MaximumFailures = 20;
    private const float Largest = float.MaxValue;
    private const int Spans = 64;

    private static readonly (int Start, int End)[] Widths =
    [
        (0, 0), (1, 1), (0, 2), (1, 4), (-5, 0), (-3, 3), (-1, 1), (0, 11), (-11, 0), (0, 15), (0, 30), (0, 31), (0, 62), (0, 63), (0, 64), (-33, 32), (0, 100), (-95, 0), (0, 255), (-128, 127), (-255, 0),
        (-700, 700), (5, 9), (-9, -5)
    ];

    /// <summary>Verifies the proof classes, with their availability flags, against both oracles.</summary>
    [Fact]
    public void TheProofClassesMatchTheOraclesForEverySpanAndCountsClass()
    {
        var failures = new List<string>();
        var sets = ProofSets.ForSequences(Rows, includeReal: false, includeAllFalse: true);
        for (var kind = 0; kind < ProofCounts.SafetyKinds; kind++)
        {
            var counts = ProofCounts.Build(kind, Rows, 7, 101);
            for (var setIndex = 0; setIndex < sets.Length; setIndex++)
            {
                for (var index = 0; index < Widths.Length; index++)
                    Compare(sets[setIndex].First, sets[setIndex].Available, counts, Widths[index], string.Create(CultureInfo.InvariantCulture, $"{sets[setIndex].Name} counts {kind}"), failures);
            }
        }

        ProofBar.Fail("Offset validity over the proof classes", failures);
    }

    /// <summary>Verifies series that mix values near the largest double with small ones, all available and with gaps in availability, against both oracles.</summary>
    [Fact]
    public void NearOverflowMixesMatchTheOracles()
    {
        var failures = new List<string>();
        var random = new Random(20261120);
        for (var series = 0; series < 12; series++)
        {
            var values = new float[Rows];
            var flags = new bool[Rows];
            // Series 0-3: every value large, so sums overflow at once; 4-7: large values of alternating sign, whose sums come back; 8-11: a few large values among small ones.
            for (var row = 0; row < Rows; row++)
            {
                values[row] = series switch
                {
                    < 4 => (0.4f + 0.6f * random.NextSingle()) * Largest * (random.Next(4) == 0 ? -1f : 1f),
                    < 8 => (row & 1) == 0 ? Largest * (0.8f + 0.2f * random.NextSingle()) : -Largest * (0.8f + 0.2f * random.NextSingle()),
                    _ => random.Next(9) == 0 ? Largest * (random.NextSingle() - 0.5f) : (random.NextSingle() - 0.5f) * 1e6f
                };
                flags[row] = series % 2 == 0 || random.Next(40) != 0;
            }

            for (var kind = 0; kind < ProofCounts.SafetyKinds; kind++)
            {
                var counts = ProofCounts.Build(kind, Rows, 13, 211);
                for (var index = 0; index < Widths.Length; index++)
                    Compare(values, flags, counts, Widths[index], string.Create(CultureInfo.InvariantCulture, $"mix {series} counts {kind}"), failures);
            }
        }

        ProofBar.Fail("Offset validity over near-overflow mixes", failures);
    }

    /// <summary>Verifies random series of random lengths (down to a few rows, past the lane groups and the series edges) and random spans against both oracles.</summary>
    [Fact]
    public void RandomSeriesMatchTheOracles()
    {
        var failures = new List<string>();
        var random = new Random(1120);
        for (var trial = 0; trial < 400; trial++)
        {
            var length = trial < 80 ? 1 + trial : 1 + random.Next(Rows);
            var values = new float[length];
            var flags = new bool[length];
            var largeShare = random.Next(6);
            for (var row = 0; row < length; row++)
            {
                values[row] = random.Next(6) < largeShare ? Largest * (random.NextSingle() - 0.5f) * 2f : (random.NextSingle() - 0.5f) * MathF.Pow(10f, random.Next(-37, 38));
                flags[row] = random.Next(30) != 0;
            }

            var counts = ProofCounts.Build(random.Next(ProofCounts.SafetyKinds), length, 1 + random.Next(20), 1 + random.Next(300));
            var start = random.Next(-Spans - 3, Spans + 3);
            var end = start + random.Next(0, 2 * Spans + 70);
            Compare(values, flags, counts, (start, end), string.Create(CultureInfo.InvariantCulture, $"random {trial} of {length} rows"), failures);
        }

        ProofBar.Fail("Offset validity over random series", failures);
    }

    private static void Compare(float[] x, bool[] xValid, float[] counts, (int Start, int End) span, string label, List<string> failures)
    {
        var plain = OffsetValidityOracle.Plain(x, xValid, counts, span.Start, span.End);
        var prior = OffsetValidityOracle.Prior(x, xValid, counts, span.Start, span.End);
        var series = MathBlockValue.Vector(x);
        var availability = MathBlockValue.BooleanVector(xValid);
        var countsValue = MathBlockValue.Vector(counts);
        const string Name = "sum-over-offsets";
        var actual = SequenceOps.Operation(Name, true).Evaluate(SequenceOps.Inputs(Name, true, series, availability, countsValue, span.Start, span.End)).AsBooleanVector().ToArray();
        for (var row = 0; row < actual.Length && failures.Count < MaximumFailures; row++)
        {
            if (actual[row] != plain[row] || actual[row] != prior[row])
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} [{span.Start},{span.End}] row {row}: validity {actual[row]}, scan {plain[row]}, earlier path {prior[row]}"));
        }
    }
}
