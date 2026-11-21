using System.Globalization;
using System.Reflection;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The kernel of sequence.maximum-over-offsets@1 and its validity against the sequential scan it replaced (a maximum from negative infinity by Math.Max, row by row), compared bit for bit
/// in value (NaN payloads, signed zeros, infinities) and in validity. A vector cannot hold a NaN or an infinity, so the public operation never sees one; these tests call the internal kernel
/// directly with such values, so the result does not depend on that guard. They cover a NaN at every position of the window with every payload, several NaNs with different payloads, all-NaN
/// windows, signed zeros in every order, infinities, spans wider than the series, negative and positive span ends, unavailable rows inside the window (also holding a NaN), and the proof class
/// matrix with random series.
/// </summary>
public sealed class MaximumOverOffsetsKernelTests
{
    private const int MaximumFailures = 20;
    private const float Fill = 123.5f;
    private const float StaleValue = -9876.5f;

    private static readonly ValuesKernel Values = Bind<ValuesKernel>("MaximumOverOffsetsValues");
    private static readonly ValidityKernel Validity = Bind<ValidityKernel>("MaximumOverOffsetsValidity");

    // Quiet and signaling NaNs of both signs with different payloads.
    private static readonly float[] Nans =
    [
        Bits(0x7FC00000u), Bits(0x7FC00001u), Bits(0x7FC0ABCDu), Bits(0xFFC00000u), Bits(0xFFC00042u), Bits(0x7F800001u), Bits(0x7FA00000u)
    ];

    private static readonly (int Start, int End)[] WideRanges =
    [
        (0, 1000), (-1000, 1000), (-3, 100_000), (5, 2_000_000_000), (-2_000_000_000, 2_000_000_000), (-7, -2), (3, 9), (-63, 0), (0, 255), (-2_000_000_000, 0), (-5, 2_000_000_000)
    ];

    private delegate void ValuesKernel(ReadOnlySpan<float> x, ReadOnlySpan<bool> xValid, ReadOnlySpan<float> counts, int start, int end, float fill, Span<float> values, Span<bool> rowValid);

    private delegate void ValidityKernel(ReadOnlySpan<float> x, ReadOnlySpan<bool> xValid, ReadOnlySpan<float> counts, int start, int end, Span<bool> rowValid);

    /// <summary>Verifies that a vector refuses a NaN and both infinities, so the public operation never sees one.</summary>
    [Fact]
    public void AVectorRefusesANaNAndAnInfinity()
    {
        Assert.Throws<ArgumentException>(() => MathBlockValue.Vector(new float[] { 0f, float.NaN }));
        Assert.Throws<ArgumentException>(() => MathBlockValue.Vector(new float[] { 0f, float.PositiveInfinity }));
        Assert.Throws<ArgumentException>(() => MathBlockValue.Vector(new float[] { float.NegativeInfinity, 0f }));
    }

    /// <summary>Verifies a single NaN with every payload at every position of every window, for spans of widths 1 to 64 that start before, at and after the row.</summary>
    [Fact]
    public void ANaNAtAnyPositionOfTheWindowKeepsItsBits()
    {
        var random = new Random(11);
        var failures = new List<string>();
        int[] widths = [1, 2, 3, 4, 5, 8, 13, 16, 64];
        for (var widthIndex = 0; widthIndex < widths.Length && failures.Count < MaximumFailures; widthIndex++)
        {
            var width = widths[widthIndex];
            var length = 3 * width + 4;
            var background = new float[length];
            for (var row = 0; row < length; row++)
                background[row] = random.Next(0, 9) switch { 0 => float.PositiveInfinity, 1 => float.NegativeInfinity, 2 => 0f, 3 => -0f, _ => Tenth((random.NextSingle() - 0.5f) * 8f) };
            var available = AllTrue(length);
            var counts = Contiguous(length);
            (int Start, int End)[] spans = [(0, width - 1), (-(width - 1), 0), (-(width / 2), width - 1 - (width / 2)), (1, width), (-width, -1)];
            for (var position = 0; position < length; position++)
            {
                for (var payload = 0; payload < Nans.Length; payload++)
                {
                    var series = (float[])background.Clone();
                    series[position] = Nans[payload];
                    for (var index = 0; index < spans.Length; index++)
                        Check(Label(string.Create(CultureInfo.InvariantCulture, $"one NaN {payload} at {position}, width {width}"), spans[index]), series, available, counts, spans[index].Start, spans[index].End, failures);
                }
            }
        }

        ProofBar.Fail("One NaN in the window", failures);
    }

    /// <summary>Verifies two NaNs at every pair of positions in both payload orders, and random triples, so the NaN that the scan keeps is the same one.</summary>
    [Fact]
    public void SeveralNaNsWithDifferentPayloadsKeepTheBitsOfTheFirst()
    {
        var random = new Random(12);
        var failures = new List<string>();
        const int length = 36;
        var available = AllTrue(length);
        var counts = Contiguous(length);
        int[] widths = [2, 3, 5, 8, 17];
        (int First, int Second)[] payloads = [(0, 1), (1, 0), (3, 2), (5, 6), (4, 3), (2, 2)];
        for (var widthIndex = 0; widthIndex < widths.Length && failures.Count < MaximumFailures; widthIndex++)
        {
            var width = widths[widthIndex];
            (int Start, int End)[] spans = [(0, width - 1), (-(width - 1), 0), (-(width / 2), width - 1 - (width / 2))];
            for (var first = 0; first < length; first++)
            {
                for (var second = first + 1; second < length; second++)
                {
                    for (var pair = 0; pair < payloads.Length; pair++)
                    {
                        var series = new float[length];
                        for (var row = 0; row < length; row++)
                            series[row] = Tenth(random.NextSingle() * 4f);
                        series[first] = Nans[payloads[pair].First];
                        series[second] = Nans[payloads[pair].Second];
                        for (var index = 0; index < spans.Length; index++)
                            Check(Label(string.Create(CultureInfo.InvariantCulture, $"two NaNs {first} and {second} payloads {payloads[pair].First},{payloads[pair].Second}, width {width}"), spans[index]), series, available, counts, spans[index].Start, spans[index].End, failures);
                    }
                }
            }
        }

        for (var round = 0; round < 4000 && failures.Count < MaximumFailures; round++)
        {
            var series = new float[length];
            for (var row = 0; row < length; row++)
                series[row] = random.Next(0, 5) == 0 ? Nans[random.Next(Nans.Length)] : Tenth(random.NextSingle() * 4f);
            var start = random.Next(-12, 12);
            var end = start + random.Next(0, 14);
            Check(string.Create(CultureInfo.InvariantCulture, $"NaN triples round {round} [{start},{end}]"), series, available, counts, start, end, failures);
        }

        ProofBar.Fail("Several NaNs in the window", failures);
    }

    /// <summary>Verifies series of NaNs of distinct payloads (every window all NaN) and series of finite values over every span that starts from 45 before to 45 after the row, including spans wider than the series.</summary>
    [Fact]
    public void AllNaNWindowsAndSpansWiderThanTheSeriesMatch()
    {
        var failures = new List<string>();
        for (var length = 0; length <= 40 && failures.Count < MaximumFailures; length++)
        {
            var nans = new float[length];
            var finite = new float[length];
            for (var row = 0; row < length; row++)
            {
                nans[row] = Bits(0x7FC00000u | (uint)(row + 1));
                finite[row] = (row * 7 % 11) - 5f;
            }

            var available = AllTrue(length);
            var counts = Contiguous(length);
            for (var start = -45; start <= 45; start++)
            {
                for (var end = start; end <= start + 50 && failures.Count < MaximumFailures; end += end < start + 8 ? 1 : 7)
                {
                    Check(string.Create(CultureInfo.InvariantCulture, $"all NaN n={length} [{start},{end}]"), nans, available, counts, start, end, failures);
                    Check(string.Create(CultureInfo.InvariantCulture, $"finite n={length} [{start},{end}]"), finite, available, counts, start, end, failures);
                }
            }

            for (var index = 0; index < WideRanges.Length && failures.Count < MaximumFailures; index++)
            {
                Check(Label(string.Create(CultureInfo.InvariantCulture, $"all NaN n={length}"), WideRanges[index]), nans, available, counts, WideRanges[index].Start, WideRanges[index].End, failures);
                Check(Label(string.Create(CultureInfo.InvariantCulture, $"finite n={length}"), WideRanges[index]), finite, available, counts, WideRanges[index].Start, WideRanges[index].End, failures);
            }
        }

        ProofBar.Fail("All NaN windows and spans wider than the series", failures);
    }

    /// <summary>Verifies every series of positive and negative zero up to length 10 (also with a finite negative value, and with both infinities) over spans from 3 before to 3 after the row.</summary>
    [Fact]
    public void SignedZerosInEveryOrderAndInfinitiesMatch()
    {
        var failures = new List<string>();
        Exhaustive("zeros", [0f, -0f], 10, 3, failures);
        Exhaustive("zeros and a negative", [0f, -0f, -1.5f], 7, 3, failures);
        Exhaustive("zeros and infinities", [0f, -0f, float.NegativeInfinity, float.PositiveInfinity, 2.5f], 6, 2, failures);
        ProofBar.Fail("Signed zeros and infinities", failures);
    }

    /// <summary>Verifies random series drawn from NaNs of several payloads, both zeros, both infinities and finite values (with ties), random availability (the unavailable rows also hold such values), counts cut into segments or arbitrary, and spans of every kind.</summary>
    [Fact]
    public void RandomSeriesOfSpecialValuesWithUnavailableRowsMatch()
    {
        var random = new Random(20261120);
        var failures = new List<string>();
        for (var round = 0; round < 6000 && failures.Count < MaximumFailures; round++)
        {
            var length = round % 25 == 0 ? random.Next(200, 600) : random.Next(0, 70);
            var nanShare = random.Next(0, 4) switch { 0 => 0f, 1 => 0.02f, 2 => 0.1f, _ => 0.5f };
            var invalidShare = random.Next(0, 3) switch { 0 => 0f, 1 => 0.03f, _ => 0.4f };
            var series = new float[length];
            var available = new bool[length];
            for (var row = 0; row < length; row++)
            {
                series[row] = random.NextSingle() < nanShare ? Nans[random.Next(Nans.Length)] : Special(random);
                available[row] = random.NextSingle() >= invalidShare;
            }

            var counts = Counts(random, length, round % 3);
            var spanLength = random.Next(0, 4) switch { 0 => 3, 1 => 12, 2 => 70, _ => 400 };
            var start = random.Next(-spanLength, spanLength);
            var end = start + random.Next(0, spanLength);
            Check(string.Create(CultureInfo.InvariantCulture, $"random round {round} n={length} counts class {round % 3} [{start},{end}]"), series, available, counts, start, end, failures);
        }

        ProofBar.Fail("Random special series", failures);
    }

    /// <summary>
    /// Verifies a NaN in each unavailable row of a series whose other rows are finite: the row is invalid wherever its window holds such a row, and a window that holds none keeps the bits of the scan
    /// (the block tables hold the NaN of a neighbouring window, which must not reach a valid row).
    /// </summary>
    [Fact]
    public void ANaNInAnUnavailableRowNeverReachesAValidRow()
    {
        var failures = new List<string>();
        const int length = 40;
        var counts = Contiguous(length);
        int[] widths = [1, 2, 3, 4, 7, 8, 16];
        for (var widthIndex = 0; widthIndex < widths.Length && failures.Count < MaximumFailures; widthIndex++)
        {
            var width = widths[widthIndex];
            (int Start, int End)[] spans = [(0, width - 1), (-(width - 1), 0), (-(width / 2), width - 1 - (width / 2)), (2, 1 + width)];
            for (var position = 0; position < length; position++)
            {
                var series = new float[length];
                var available = AllTrue(length);
                for (var row = 0; row < length; row++)
                    series[row] = (row * 5 % 9) - 4f;
                series[position] = Nans[position % Nans.Length];
                available[position] = false;
                for (var index = 0; index < spans.Length; index++)
                    Check(Label(string.Create(CultureInfo.InvariantCulture, $"unavailable NaN at {position}, width {width}"), spans[index]), series, available, counts, spans[index].Start, spans[index].End, failures);
            }
        }

        ProofBar.Fail("A NaN in an unavailable row", failures);
    }

    /// <summary>Verifies the proof class matrix (every class, the four counts classes, the safety spans and wide spans) and the same classes with a NaN of a distinct payload in each unavailable row.</summary>
    [Fact]
    public void TheClassMatrixMatchesTheSequentialScan()
    {
        const int rows = 2500;
        var sets = ProofSets.ForSequences(rows, includeReal: true, includeAllFalse: true);
        var failures = new List<string>();
        for (var setIndex = 0; setIndex < sets.Length && failures.Count < MaximumFailures; setIndex++)
        {
            var set = sets[setIndex];
            var withNans = (float[])set.First.Clone();
            for (var row = 0; row < rows; row++)
            {
                if (!set.Available[row])
                    withNans[row] = Bits(0x7FC00000u | (uint)(row + 1));
            }

            for (var kind = 0; kind < ProofCounts.SafetyKinds && failures.Count < MaximumFailures; kind++)
            {
                var counts = ProofCounts.Build(kind, rows, 7, 101);
                for (var index = 0; index < SequenceOps.SpanSafety.Length && failures.Count < MaximumFailures; index++)
                    CheckBoth(set, withNans, counts, kind, ((int)SequenceOps.SpanSafety[index].First, (int)SequenceOps.SpanSafety[index].Second), failures);
                for (var index = 0; index < WideRanges.Length && failures.Count < MaximumFailures; index++)
                    CheckBoth(set, withNans, counts, kind, WideRanges[index], failures);
            }
        }

        ProofBar.Fail("Class matrix against the sequential scan", failures);
    }

    // The scan that the van Herk kernel replaced: the maximum of the span of each reachable row from negative infinity by Math.Max, the row invalid at the first unavailable row.
    // The first NaN of a span keeps its bits (Larger): Math.Max leaves the bits of the NaN it returns to the runtime, so the scan's rule is written out.
    private static void OldScan(float[] x, bool[] available, float[] counts, int start, int end, float[] values, bool[] valid)
    {
        for (var row = 0; row < x.Length; row++)
        {
            var ok = Reachable(counts, row, start, end);
            var maximum = float.NegativeInfinity;
            for (long index = row + (long)start; ok && index <= row + (long)end; index++)
            {
                if (!available[(int)index])
                    ok = false;
                else
                    maximum = Larger(maximum, x[(int)index]);
            }

            valid[row] = ok;
            values[row] = ok ? maximum : Fill;
        }
    }

    private static float Larger(float maximum, float value) => float.IsNaN(maximum) ? maximum : float.IsNaN(value) ? value : Math.Max(maximum, value);

    private static bool Reachable(float[] counts, int row, int start, int end)
    {
        long before = start < 0 ? -(long)start : 0L;
        long after = end > 0 ? end : 0L;
        if (row + (long)start < 0 || counts[row] < before)
            return false;
        var last = row + after;
        return last < counts.Length && counts[(int)last] >= after;
    }

    private static void CheckBoth(ProofSet set, float[] withNans, float[] counts, int kind, (int Start, int End) span, List<string> failures)
    {
        var label = string.Create(CultureInfo.InvariantCulture, $"class {set.Name} counts {kind} [{span.Start},{span.End}]");
        Check(label, set.First, set.Available, counts, span.Start, span.End, failures);
        Check(label + " NaNs in the unavailable rows", withNans, set.Available, counts, span.Start, span.End, failures);
    }

    private static void Check(string label, float[] x, bool[] available, float[] counts, int start, int end, List<string> failures)
    {
        if (failures.Count >= MaximumFailures)
            return;
        var length = x.Length;
        var expectedValues = new float[length];
        var expectedValid = new bool[length];
        OldScan(x, available, counts, start, end, expectedValues, expectedValid);

        // The kernel writes every row: start from values that no row would hold.
        var actualValues = new float[length];
        var actualValid = new bool[length];
        Array.Fill(actualValues, StaleValue);
        Array.Fill(actualValid, true);
        Values(x, available, counts, start, end, Fill, actualValues, actualValid);
        var siblingValid = new bool[length];
        Array.Fill(siblingValid, true);
        Validity(x, available, counts, start, end, siblingValid);
        for (var row = 0; row < length && failures.Count < MaximumFailures; row++)
        {
            if (actualValid[row] != expectedValid[row])
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: validity {actualValid[row]}, scan {expectedValid[row]}"));
            else if (siblingValid[row] != expectedValid[row])
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: the -valid form gives {siblingValid[row]}, scan {expectedValid[row]}"));
            else if (BitConverter.SingleToInt32Bits(actualValues[row]) != BitConverter.SingleToInt32Bits(expectedValues[row]))
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: bits {BitConverter.DoubleToInt64Bits(actualValues[row]):X16} ({actualValues[row]:R}), scan {BitConverter.DoubleToInt64Bits(expectedValues[row]):X16} ({expectedValues[row]:R})"));
        }
    }

    private static void Exhaustive(string name, float[] alphabet, int maximumLength, int reach, List<string> failures)
    {
        for (var length = 1; length <= maximumLength && failures.Count < MaximumFailures; length++)
        {
            var available = AllTrue(length);
            var counts = Contiguous(length);
            var series = new float[length];
            var total = 1L;
            for (var row = 0; row < length; row++)
                total *= alphabet.Length;
            for (long code = 0; code < total && failures.Count < MaximumFailures; code++)
            {
                var rest = code;
                for (var row = 0; row < length; row++)
                {
                    series[row] = alphabet[(int)(rest % alphabet.Length)];
                    rest /= alphabet.Length;
                }

                for (var start = -reach; start <= reach; start++)
                {
                    for (var end = start; end <= start + reach + 2; end++)
                        Check(string.Create(CultureInfo.InvariantCulture, $"{name} n={length} code {code} [{start},{end}]"), series, available, counts, start, end, failures);
                }
            }
        }
    }

    private static float Special(Random random) =>
        random.Next(0, 10) switch
        {
            0 => 0f,
            1 => -0f,
            2 => float.PositiveInfinity,
            3 => float.NegativeInfinity,
            4 => 3.38e38f,
            5 => -3.38e38f,
            _ => Tenth((random.NextSingle() - 0.5f) * 6f)
        };

    // Class 0: contiguity counts with random restarts. Class 1: contiguity counts with a first count above zero. Class 2: arbitrary counts.
    private static float[] Counts(Random random, int length, int kind)
    {
        var counts = new float[length];
        for (var row = 0; row < length; row++)
        {
            var previous = row == 0 ? 0f : counts[row - 1];
            counts[row] = kind switch
            {
                0 => row == 0 || random.NextSingle() < 0.1f ? 0f : previous + 1f,
                1 => row == 0 ? random.Next(1, 5) : (random.NextSingle() < 0.1f ? 0f : previous + 1f),
                _ => random.Next(0, 12)
            };
        }

        return counts;
    }

    private static float[] Contiguous(int length)
    {
        var counts = new float[length];
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

    private static float Tenth(float value) => MathF.Round(value, 1, MidpointRounding.ToEven);

    private static float Bits(uint bits) => BitConverter.UInt32BitsToSingle(bits);

    private static T Bind<T>(string name)
        where T : Delegate =>
        (T)Delegate.CreateDelegate(typeof(T), typeof(MathBlockVectorMath).GetMethod(name, BindingFlags.NonPublic | BindingFlags.Static)!);
}
