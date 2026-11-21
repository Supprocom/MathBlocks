using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The CoreCLR route of sequence.prefix-difference-over-offsets@1 and its -valid sibling (MathBlockCudaDeviceModule.GetOperation(...).EvaluateCoreCLR, with values, with a span, and for the
/// validity) against the algorithm from before the rewrite (<see cref="PrefixDifferenceOldAlgorithm"/>): every row's value bits and validity over the proof class matrix, over random
/// series (also with subnormal magnitudes, magnitudes at the edge of the scaled domain and near the largest double), over counts cut into segments and over arbitrary counts, and over
/// spans that start before the series or a segment and end inside, at and past a segment's end.
/// </summary>
public sealed class PrefixDifferenceEquivalenceTests
{
    private const string Form = "sequence.prefix-difference-over-offsets@1";
    private const string Valid = "sequence.prefix-difference-over-offsets-valid@1";
    private const int MatrixRows = 1200;
    private const int MaximumFailures = 20;

    private static readonly ProofParameter[] WideSpans =
    [
        new("[0,1000]", 0f, 1000f, 1001f), new("[-1000,1000]", -1000f, 1000f, 2001f), new("[-3,100000]", -3f, 100_000f, 100_004f), new("[5,2000000000]", 5f, 2_000_000_000f, 2_000_000_000f),
        new("[-2000000000,2000000000]", -2_000_000_000f, 2_000_000_000f, 4_000_000_001f), new("[-7,-2]", -7f, -2f, 6f), new("[3,9]", 3f, 9f, 7f), new("[-63,0]", -63f, 0f, 64f),
        new("[-1e300,0]", -3.16e37f, 0f, 1f), new("[0,1e300]", 0f, 3.16e37f, 1f), new("[-1199,0]", -1199f, 0f, 1200f), new("[0,1199]", 0f, 1199f, 1200f), new("[-1200,0]", -1200f, 0f, 1201f),
        new("[0,1200]", 0f, 1200f, 1201f), new("[-600,599]", -600f, 599f, 1200f), new("[-0,-0]", -0f, -0f, 1f)
    ];

    /// <summary>Verifies the class matrix at 1,200 rows over the safety spans and the wide spans, for all four counts classes.</summary>
    [Fact]
    public void BothFormsMatchTheOldAlgorithmOverTheClassMatrix()
    {
        var sets = ProofSets.ForSequences(MatrixRows, includeReal: true, includeAllFalse: true);
        ProofParameter[] spans = [.. SequenceOps.SpanSafety, .. SequenceOps.SpanTiming, .. WideSpans];
        var failures = new List<string>();
        for (var setIndex = 0; setIndex < sets.Length; setIndex++)
        {
            var set = sets[setIndex];
            for (var kind = 0; kind < ProofCounts.SafetyKinds; kind++)
            {
                var counts = ProofCounts.Build(kind, MatrixRows, 7, 101);
                for (var index = 0; index < spans.Length && failures.Count < MaximumFailures; index++)
                    Compare(string.Concat(set.Name, "/", ProofCounts.Name(kind, 7, 101), "/", spans[index].Label), set.First, set.Available, counts, spans[index].First, spans[index].Second, SequenceOps.Fill, failures);
            }
        }

        ProofBar.Fail("Class matrix", failures);
    }

    /// <summary>Verifies random series over every scale (subnormal, the edge of the scaled domain, ordinary, near the largest double), random availability, counts and spans.</summary>
    [Fact]
    public void BothFormsMatchTheOldAlgorithmOverRandomSeries()
    {
        var random = new Random(20261120);
        var failures = new List<string>();
        float[] scales = [1f, 1e5f, 3.16e37f, 3.38e38f, 5.28e-41f, 1.4e-45f, 1.4e-45f, 3.8e-34f, 3.81e-34f, 1.03e-37f, 1.1754943e-38f];
        for (var round = 0; round < 3000 && failures.Count < MaximumFailures; round++)
        {
            var length = round % 10 == 0 ? random.Next(200, 1500) : random.Next(1, 45);
            var scale = scales[random.Next(scales.Length)];
            var invalidShare = random.Next(0, 3) switch { 0 => 0f, 1 => 0.03f, _ => 0.4f };
            var series = new float[length];
            var available = new bool[length];
            for (var row = 0; row < length; row++)
            {
                series[row] = Value(random, scale, round);
                available[row] = random.NextSingle() >= invalidShare;
            }

            var counts = RandomCounts(random, length, round % 3);
            var spanLength = random.Next(0, 4) switch { 0 => 3, 1 => 12, 2 => 70, _ => 3000 };
            var start = random.Next(-spanLength, spanLength);
            var end = start + random.Next(0, spanLength);
            var fill = random.Next(4) switch { 0 => SequenceOps.Fill, 1 => 0f, 2 => -0f, _ => 5.28e-41f };
            var label = string.Create(CultureInfo.InvariantCulture, $"round {round} n={length} scale {scale:R} counts class {round % 3} [{start},{end}] fill {fill:R}");
            Compare(label, series, available, counts, start, end, fill, failures);
        }

        ProofBar.Fail("Random series", failures);
    }

    /// <summary>Verifies every span with a start from -9 to 9 over series of every length up to 70 cut into segments of every small length, with unavailable rows, at ordinary and subnormal scales.</summary>
    [Fact]
    public void ShortSeriesAndEverySmallSpanMatchTheOldAlgorithm()
    {
        var random = new Random(18112026);
        var failures = new List<string>();
        int[] segmentLengths = [1, 2, 3, 5, 11, 1000];
        float[] scales = [100f, 1.4e-45f, 3.16e37f];
        for (var length = 1; length <= 70 && failures.Count < MaximumFailures; length++)
        {
            for (var segmentIndex = 0; segmentIndex < segmentLengths.Length; segmentIndex++)
            {
                var counts = new float[length];
                for (var row = 0; row < length; row++)
                    counts[row] = row % segmentLengths[segmentIndex] == 0 ? 0f : counts[row - 1] + 1f;
                for (var scaleIndex = 0; scaleIndex < scales.Length; scaleIndex++)
                {
                    var series = new float[length];
                    var available = new bool[length];
                    for (var row = 0; row < length; row++)
                    {
                        available[row] = random.NextSingle() >= 0.1f;
                        series[row] = (random.NextSingle() - 0.4f) * scales[scaleIndex];
                    }

                    for (var start = -9; start <= 9 && failures.Count < MaximumFailures; start++)
                    {
                        for (var end = start; end <= start + 8 && failures.Count < MaximumFailures; end++)
                            Compare(string.Create(CultureInfo.InvariantCulture, $"n={length} segments {segmentLengths[segmentIndex]} scale {scales[scaleIndex]:R} [{start},{end}]"), series, available, counts, start, end, SequenceOps.Fill, failures);
                    }
                }
            }
        }

        ProofBar.Fail("Short series", failures);
    }

    /// <summary>
    /// Verifies the scaled domain: runs of subnormals whose sums cross into the normal range and back (exactly cancelling pairs, positive and negative zeros, the smallest subnormal),
    /// values just below and just above the limit of the scaled domain, and one large value among subnormals.
    /// </summary>
    [Fact]
    public void SubnormalSumsAndTheEdgeOfTheScaledDomainMatchTheOldAlgorithm()
    {
        var random = new Random(7);
        var failures = new List<string>();
        var limit = MathBlockSimdLimit();
        float[] specials = [0f, -0f, float.Epsilon, -float.Epsilon, 1.1754943e-38f, -1.1754943e-38f, 1.1754943e-38f, -1.1754943e-38f, limit, -limit, BitConverter.Int32BitsToSingle(BitConverter.SingleToInt32Bits(limit) - 1), -BitConverter.Int32BitsToSingle(BitConverter.SingleToInt32Bits(limit) - 1)];
        ProofParameter[] spans = [.. SequenceOps.SpanTiming, new("[-1,0]", -1f, 0f, 2f), new("[1,1]", 1f, 1f, 1f), new("[0,7]", 0f, 7f, 8f), new("[-8,-1]", -8f, -1f, 8f)];
        for (var round = 0; round < 400 && failures.Count < MaximumFailures; round++)
        {
            var length = round < 300 ? random.Next(1, 90) : 1000;
            var series = new float[length];
            var available = new bool[length];
            for (var row = 0; row < length; row++)
            {
                series[row] = random.Next(0, 4) switch
                {
                    0 => specials[random.Next(specials.Length)],
                    1 => (random.Next(2) == 0 ? 1f : -1f) * BitConverter.Int32BitsToSingle(1 + random.Next((1 << 23) - 1)),
                    2 => (random.Next(2) == 0 ? 1f : -1f) * BitConverter.Int32BitsToSingle((1 << 23) + random.Next(1 << 23)),
                    _ => row > 0 && random.Next(2) == 0 ? -series[row - 1] : BitConverter.Int32BitsToSingle(random.Next(1 << 24))
                };
                available[row] = round % 4 == 0 || random.NextSingle() >= 0.15f;
            }

            if (round % 5 == 0)
                series[random.Next(length)] = 3.16e37f;
            var counts = RandomCounts(random, length, round % 3);
            for (var index = 0; index < spans.Length && failures.Count < MaximumFailures; index++)
                Compare(string.Create(CultureInfo.InvariantCulture, $"scaled round {round} n={length} {spans[index].Label}"), series, available, counts, spans[index].First, spans[index].Second, SequenceOps.Fill, failures);
        }

        ProofBar.Fail("Scaled domain", failures);
    }

    /// <summary>Verifies the calls that are invalid as a whole (a fractional or infinite offset, start above end, a count that is negative or not an integer) and that inputs of unequal lengths are refused by the type rules, as for the other offset operations.</summary>
    [Fact]
    public void CallsInvalidAsAWholeStayInvalid()
    {
        var series = MathBlockValue.Vector([1f, 2f, 3f]);
        var flags = MathBlockValue.BooleanVector([true, true, true]);
        var counts = MathBlockValue.Vector([0f, 1f, 2f]);
        var form = MathBlockCudaDeviceModule.GetOperation(Form);
        var valid = MathBlockCudaDeviceModule.GetOperation(Valid);
        Assert.True(form.EvaluateCoreCLR(series, flags, counts, MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f), MathBlockValue.Scalar(-1f)).IsValid);
        MathBlockValue[][] unequal =
        [
            [series, MathBlockValue.BooleanVector([true, true]), counts, MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f)],
            [series, flags, MathBlockValue.Vector([0f, 1f]), MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f)]
        ];
        for (var index = 0; index < unequal.Length; index++)
        {
            var inputs = unequal[index];
            Assert.Throws<InvalidOperationException>(() => valid.EvaluateCoreCLR(inputs));
            Assert.Throws<InvalidOperationException>(() => form.EvaluateCoreCLR([.. inputs, MathBlockValue.Scalar(-1f)]));
        }

        MathBlockValue[][] broken =
        [
            [series, flags, counts, MathBlockValue.Scalar(0.5f), MathBlockValue.Scalar(1f)],
            [series, flags, counts, MathBlockValue.Scalar(0f), MathBlockValue.Scalar(float.PositiveInfinity)],
            [series, flags, counts, MathBlockValue.Scalar(2f), MathBlockValue.Scalar(1f)],
            [series, flags, MathBlockValue.Vector([0f, -1f, 2f]), MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f)],
            [series, flags, MathBlockValue.Vector([0f, 1.5f, 2f]), MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f)]
        ];
        for (var index = 0; index < broken.Length; index++)
        {
            Assert.False(valid.EvaluateCoreCLR(broken[index]).IsValid, string.Create(CultureInfo.InvariantCulture, $"validity case {index}"));
            MathBlockValue[] formInputs = [.. broken[index], MathBlockValue.Scalar(-1f)];
            Assert.False(form.EvaluateCoreCLR(formInputs).IsValid, string.Create(CultureInfo.InvariantCulture, $"form case {index}"));
        }
    }

    private static float MathBlockSimdLimit() => BitConverter.Int32BitsToSingle((127 - 100) << 23);

    // A value of the scale: ordinary random, or now and then an exact zero, a negative zero, the previous kind of edge, or a value ten magnitudes up (a large one among small ones).
    private static float Value(Random random, float scale, int round)
    {
        var ordinary = (random.NextSingle() * 2f - 1f) * scale;
        var value = random.Next(0, 12) switch
        {
            0 => 0f,
            1 => -0f,
            2 => scale * 1e6f * (random.NextSingle() - 0.5f),
            3 when round % 7 == 0 => scale * 1e30f * (random.NextSingle() - 0.5f),
            _ => ordinary
        };

        // A vector holds finite values only: at the largest scales the wider kinds overflow, and the ordinary value of the scale stands in.
        return float.IsFinite(value) ? value : ordinary;
    }

    // Counts of kind 0: segments cut at random zeros; 1: arbitrary non-negative integers with many zeros; 2: one segment.
    private static float[] RandomCounts(Random random, int length, int kind)
    {
        var counts = new float[length];
        for (var row = 0; row < length; row++)
        {
            counts[row] = kind switch
            {
                0 => row == 0 || random.NextSingle() < 0.1f ? 0f : counts[row - 1] + 1f,
                1 => random.NextSingle() < 0.2f ? 0f : MathF.Floor(random.NextSingle() * 50f),
                _ => row
            };
        }

        return counts;
    }

    private static void Compare(string label, float[] series, bool[] available, float[] counts, float start, float end, float fill, List<string> failures)
    {
        var expected = PrefixDifferenceOldAlgorithm.Run(series, available, counts, start, end, fill);
        var seriesValue = MathBlockValue.Vector(series);
        var availability = MathBlockValue.BooleanVector(available);
        var countsValue = MathBlockValue.Vector(counts);
        var formInputs = new[] { seriesValue, availability, countsValue, MathBlockValue.Scalar(start), MathBlockValue.Scalar(end), MathBlockValue.Scalar(fill) };
        var validInputs = new[] { seriesValue, availability, countsValue, MathBlockValue.Scalar(start), MathBlockValue.Scalar(end) };
        var values = MathBlockCudaDeviceModule.GetOperation(Form).EvaluateCoreCLR(formInputs);
        var flags = MathBlockCudaDeviceModule.GetOperation(Valid).EvaluateCoreCLR(validInputs);
        if (!values.IsValid || !flags.IsValid)
        {
            failures.Add(label + ": the call was invalid as a whole.");
            return;
        }

        var output = new float[series.Length + 3];
        var evaluation = MathBlockCudaDeviceModule.GetOperation(Form).EvaluateCoreCLR(formInputs, output, new MathBlockDomainOptions());
        var actualValues = values.AsVector().ToArray();
        var actualFlags = flags.AsBooleanVector().ToArray();
        if (actualValues.Length != series.Length || actualFlags.Length != series.Length || !evaluation.IsValid || evaluation.Rows != series.Length)
        {
            failures.Add(label + ": wrong length.");
            return;
        }

        for (var row = 0; row < series.Length && failures.Count < MaximumFailures; row++)
        {
            var expectedBits = BitConverter.SingleToInt32Bits(expected.Values[row]);
            if (actualFlags[row] != expected.Valid[row] || BitConverter.SingleToInt32Bits(actualValues[row]) != expectedBits || BitConverter.SingleToInt32Bits(output[row]) != expectedBits)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: expected {expected.Values[row]:R}/{expected.Valid[row]}, actual {actualValues[row]:R}/{actualFlags[row]}, span {output[row]:R}"));
        }
    }
}
