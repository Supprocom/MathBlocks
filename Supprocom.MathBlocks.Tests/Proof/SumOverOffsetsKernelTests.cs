using System.Globalization;
using System.Reflection;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The value kernel of sequence.sum-over-offsets@1 against the sequential sum that defines it (0.0 plus the span's values added left to right, row by row; invalid when a row of the span is
/// unreachable or unavailable, or when a running sum is not finite), compared bit for bit in value and in validity. The kernel adds the spans of many rows at once in vector lanes, so the
/// tests cover every series length around the sizes of its blocks, spans that start before, at and after the row and that are wider than the series, running sums that overflow in the middle
/// of a span and would be finite in another order, signed zeros, subnormal values, unavailable rows, the three kinds of counts, and values a vector cannot hold (infinities and NaNs), which
/// only a direct call can pass.
/// </summary>
public sealed class SumOverOffsetsKernelTests
{
    private const int MaximumFailures = 20;
    private const double Fill = 123.5d;
    private const double StaleValue = -9876.5d;

    private static readonly ValuesKernel Values = Bind<ValuesKernel>("SumOverOffsetsValues");
    private static readonly ValidityKernel Validity = Bind<ValidityKernel>("SumOverOffsetsValidity");

    private static readonly (int Start, int End)[] Spans =
    [
        (0, 0), (1, 1), (-1, -1), (0, 2), (1, 4), (2, 5), (-5, 0), (-2, -1), (-3, 3), (-1, 1), (3, 3), (5, 9), (-9, -5), (0, 11), (-11, 0), (0, 31), (-16, 16), (0, 63), (-95, 0), (0, 255),
        (-128, 127), (-300, 300), (0, 100_000), (-2_000_000_000, 2_000_000_000), (5, 2_000_000_000), (-2_000_000_000, 0)
    ];

    private delegate void ValuesKernel(ReadOnlySpan<double> x, ReadOnlySpan<bool> xValid, ReadOnlySpan<double> counts, int start, int end, double fill, Span<double> values, Span<bool> rowValid);

    private delegate void ValidityKernel(ReadOnlySpan<double> x, ReadOnlySpan<bool> xValid, ReadOnlySpan<double> counts, int start, int end, Span<bool> rowValid);

    /// <summary>Verifies every series length from 0 to 80 rows, and a few longer ones, for every span, with finite random values, unavailable rows and the three kinds of counts.</summary>
    [Fact]
    public void EveryLengthAroundTheBlocksMatchesTheSequentialSum()
    {
        var random = new Random(31);
        var failures = new List<string>();
        var lengths = new List<int>();
        for (var length = 0; length <= 80; length++)
            lengths.Add(length);
        lengths.AddRange([100, 127, 128, 129, 257, 1000]);
        for (var lengthIndex = 0; lengthIndex < lengths.Count && failures.Count < MaximumFailures; lengthIndex++)
        {
            var length = lengths[lengthIndex];
            for (var kind = 0; kind < 3; kind++)
            {
                var series = new double[length];
                var available = new bool[length];
                for (var row = 0; row < length; row++)
                {
                    series[row] = Finite(random);
                    available[row] = kind == 0 || random.NextDouble() >= 0.08d;
                }

                var counts = Counts(random, length, kind);
                for (var index = 0; index < Spans.Length; index++)
                    Check(Label(string.Create(CultureInfo.InvariantCulture, $"n={length} counts {kind}"), Spans[index]), series, available, counts, Spans[index].Start, Spans[index].End, true, failures);
            }
        }

        ProofBar.Fail("Lengths around the blocks", failures);
    }

    /// <summary>Verifies that a running sum that overflows in the middle of a span makes the row invalid although the same values add up to a finite sum in another order.</summary>
    [Fact]
    public void ARunningSumThatOverflowsInTheMiddleOfASpanIsInvalid()
    {
        const double Large = 1.2e308d;
        var failures = new List<string>();
        // Each pattern repeats along the series, so every lane of a block and every row past the blocks sees every alignment of it.
        double[][] patterns =
        [
            [Large, Large, -Large, -Large],
            [Large, -Large, Large, -Large],
            [-Large, -Large, Large, Large, 1d],
            [Large, 1d, Large, -Large, -Large, 2d],
            [double.MaxValue, double.MaxValue * 0.5d, -double.MaxValue, 3d]
        ];
        for (var patternIndex = 0; patternIndex < patterns.Length; patternIndex++)
        {
            var pattern = patterns[patternIndex];
            for (var length = 1; length <= 75; length++)
            {
                var series = new double[length];
                for (var row = 0; row < length; row++)
                    series[row] = pattern[row % pattern.Length];
                for (var start = -4; start <= 4; start++)
                {
                    for (var end = start; end <= start + 6; end++)
                        Check(string.Create(CultureInfo.InvariantCulture, $"overflow pattern {patternIndex} n={length} [{start},{end}]"), series, AllTrue(length), Contiguous(length), start, end, true, failures);
                }
            }
        }

        // The first row's span overflows on its second value and the same four values add up to zero in pairs.
        var four = new[] { Large, Large, -Large, -Large };
        var values = new double[4];
        var valid = new bool[4];
        Values(four, AllTrue(4), Contiguous(4), 0, 3, Fill, values, valid);
        Assert.False(valid[0]);
        Assert.Equal(Fill, values[0]);
        ProofBar.Fail("Overflow in the middle of a span", failures);
    }

    /// <summary>Verifies signed zeros in every order (a sum of negative zeros is positive zero, because the sum starts at 0.0) and subnormal values.</summary>
    [Fact]
    public void SignedZerosAndSubnormalValuesKeepTheirBits()
    {
        var failures = new List<string>();
        double[] alphabet = [0d, -0d, double.Epsilon, -double.Epsilon, 2.5e-310d, -1e-308d, 1d];
        var random = new Random(5);
        for (var length = 1; length <= 70 && failures.Count < MaximumFailures; length++)
        {
            for (var repeat = 0; repeat < 6; repeat++)
            {
                var series = new double[length];
                for (var row = 0; row < length; row++)
                    series[row] = repeat == 0 ? -0d : alphabet[random.Next(0, alphabet.Length)];
                for (var start = -3; start <= 3; start++)
                {
                    for (var end = start; end <= start + 9; end++)
                        Check(string.Create(CultureInfo.InvariantCulture, $"zeros and subnormals n={length} repeat {repeat} [{start},{end}]"), series, AllTrue(length), Contiguous(length), start, end, true, failures);
                }
            }
        }

        var zeros = new double[40];
        Array.Fill(zeros, -0d);
        var sums = new double[40];
        var valid = new bool[40];
        Values(zeros, AllTrue(40), Contiguous(40), 0, 2, Fill, sums, valid);
        Assert.True(valid[0]);
        Assert.Equal(0L, BitConverter.DoubleToInt64Bits(sums[0]));
        ProofBar.Fail("Signed zeros and subnormal values", failures);
    }

    /// <summary>Verifies series that hold infinities and NaNs (a direct call only), also in unavailable rows: a row whose span reaches one is invalid, every other row is unchanged.</summary>
    [Fact]
    public void InfinitiesAndNaNsOfADirectCallMakeTheirRowsInvalid()
    {
        var random = new Random(17);
        var failures = new List<string>();
        for (var length = 1; length <= 90 && failures.Count < MaximumFailures; length++)
        {
            for (var kind = 0; kind < 3; kind++)
            {
                var series = new double[length];
                var available = new bool[length];
                for (var row = 0; row < length; row++)
                {
                    series[row] = random.Next(0, 12) switch { 0 => double.PositiveInfinity, 1 => double.NegativeInfinity, 2 => double.NaN, 3 => 1.7e308d, 4 => -1.7e308d, _ => Finite(random) };
                    available[row] = random.NextDouble() >= 0.1d;
                }

                var counts = Counts(random, length, kind);
                for (var index = 0; index < Spans.Length; index++)
                    Check(Label(string.Create(CultureInfo.InvariantCulture, $"special values n={length} counts {kind}"), Spans[index]), series, available, counts, Spans[index].Start, Spans[index].End, false, failures);
            }
        }

        ProofBar.Fail("Infinities and NaNs of a direct call", failures);
    }

    /// <summary>Verifies the proof class matrix (every input class against the three counts classes) over the spans of the safety sweep.</summary>
    [Fact]
    public void TheClassMatrixMatchesTheSequentialSum()
    {
        const int Rows = 4096;
        var failures = new List<string>();
        var sets = ProofSets.ForSequences(Rows, includeReal: false, includeAllFalse: false);
        for (var setIndex = 0; setIndex < sets.Length && failures.Count < MaximumFailures; setIndex++)
        {
            var set = sets[setIndex];
            for (var kind = 0; kind < ProofCounts.TimingKinds; kind++)
            {
                var counts = ProofCounts.Build(kind, Rows, 10, 1000);
                for (var index = 0; index < SequenceOps.SpanSafety.Length; index++)
                {
                    var parameter = SequenceOps.SpanSafety[index];
                    Check(string.Create(CultureInfo.InvariantCulture, $"class {set.Name} counts {kind} {parameter.Label}"), set.First, set.Available, counts, (int)parameter.First, (int)parameter.Second, true, failures);
                }
            }
        }

        ProofBar.Fail("Class matrix", failures);
    }

    // The definition, written out: 0.0 plus the values of the span, left to right; invalid when the span is unreachable, a row of it is unavailable or a running sum is not finite.
    private static void SequentialSum(double[] x, bool[] available, double[] counts, int start, int end, double[] values, bool[] valid)
    {
        for (var row = 0; row < x.Length; row++)
        {
            var ok = Reachable(counts, row, start, end);
            var sum = 0d;
            for (var index = row + (long)start; ok && index <= row + (long)end; index++)
            {
                ok = available[index];
                if (ok)
                {
                    sum += x[index];
                    ok = double.IsFinite(sum);
                }
            }

            valid[row] = ok;
            values[row] = ok ? sum : Fill;
        }
    }

    private static bool Reachable(double[] counts, int row, int start, int end)
    {
        var before = start < 0 ? -(long)start : 0L;
        var after = end > 0 ? (long)end : 0L;
        if (row + (long)start < 0 || counts[row] < before)
            return false;
        var last = row + after;
        return last < counts.Length && counts[last] >= after;
    }

    private static void Check(string label, double[] x, bool[] available, double[] counts, int start, int end, bool sibling, List<string> failures)
    {
        if (failures.Count >= MaximumFailures)
            return;
        var length = x.Length;
        var expectedValues = new double[length];
        var expectedValid = new bool[length];
        SequentialSum(x, available, counts, start, end, expectedValues, expectedValid);

        // The kernel writes every row: start from values that no row would hold.
        var actualValues = new double[length];
        var actualValid = new bool[length];
        Array.Fill(actualValues, StaleValue);
        Array.Fill(actualValid, true);
        Values(x, available, counts, start, end, Fill, actualValues, actualValid);
        var siblingValid = new bool[length];
        Array.Fill(siblingValid, true);
        if (sibling)
            Validity(x, available, counts, start, end, siblingValid);
        for (var row = 0; row < length && failures.Count < MaximumFailures; row++)
        {
            if (actualValid[row] != expectedValid[row])
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: validity {actualValid[row]}, sequential sum {expectedValid[row]}"));
            else if (sibling && siblingValid[row] != expectedValid[row])
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: the -valid form gives {siblingValid[row]}, sequential sum {expectedValid[row]}"));
            else if (BitConverter.DoubleToInt64Bits(actualValues[row]) != BitConverter.DoubleToInt64Bits(expectedValues[row]))
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: bits {BitConverter.DoubleToInt64Bits(actualValues[row]):X16} ({actualValues[row]:R}), sequential sum {BitConverter.DoubleToInt64Bits(expectedValues[row]):X16} ({expectedValues[row]:R})"));
        }
    }

    // A finite value: mostly ordinary magnitudes, with signed zeros, values near the largest double and values near the smallest.
    private static double Finite(Random random) =>
        random.Next(0, 12) switch
        {
            0 => 0d,
            1 => -0d,
            2 => 1.7e308d,
            3 => -1.7e308d,
            4 => 3e-310d,
            5 => (random.NextDouble() - 0.5d) * 1e300d,
            _ => Math.Round((random.NextDouble() - 0.5d) * 6d, 1, MidpointRounding.ToEven)
        };

    // Kind 0: contiguous. Kind 1: contiguity counts with random restarts. Kind 2: arbitrary counts.
    private static double[] Counts(Random random, int length, int kind)
    {
        var counts = new double[length];
        for (var row = 0; row < length; row++)
        {
            var previous = row == 0 ? 0d : counts[row - 1];
            counts[row] = kind switch
            {
                0 => row,
                1 => row == 0 || random.NextDouble() < 0.1d ? 0d : previous + 1d,
                _ => random.Next(0, 12)
            };
        }

        return counts;
    }

    private static double[] Contiguous(int length)
    {
        var counts = new double[length];
        for (var row = 0; row < length; row++)
            counts[row] = row;
        return counts;
    }

    private static bool[] AllTrue(int length)
    {
        var flags = new bool[length];
        Array.Fill(flags, true);
        return flags;
    }

    private static string Label(string text, (int Start, int End) span) => string.Create(CultureInfo.InvariantCulture, $"{text} [{span.Start},{span.End}]");

    private static T Bind<T>(string name)
        where T : Delegate =>
        (T)Delegate.CreateDelegate(typeof(T), typeof(MathBlockVectorMath).GetMethod(name, BindingFlags.NonPublic | BindingFlags.Static)!);
}
