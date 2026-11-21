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
        new("[0,1000]", 0d, 1000d, 1001d), new("[-1000,1000]", -1000d, 1000d, 2001d), new("[-3,100000]", -3d, 100_000d, 100_004d), new("[5,2000000000]", 5d, 2_000_000_000d, 2_000_000_000d),
        new("[-2000000000,2000000000]", -2_000_000_000d, 2_000_000_000d, 4_000_000_001d), new("[-7,-2]", -7d, -2d, 6d), new("[3,9]", 3d, 9d, 7d), new("[-63,0]", -63d, 0d, 64d),
        new("[-1e300,0]", -1e300d, 0d, 1d), new("[0,1e300]", 0d, 1e300d, 1d), new("[-1199,0]", -1199d, 0d, 1200d), new("[0,1199]", 0d, 1199d, 1200d), new("[-1200,0]", -1200d, 0d, 1201d),
        new("[0,1200]", 0d, 1200d, 1201d), new("[-600,599]", -600d, 599d, 1200d), new("[-0,-0]", -0d, -0d, 1d)
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
        double[] scales = [1d, 1e5d, 1e300d, 1.7e308d, 1e-310d, 4.9e-324d, 3e-320d, 8.4e-272d, 8.6e-272d, 1e-300d, 2.2250738585072014e-308d];
        for (var round = 0; round < 3000 && failures.Count < MaximumFailures; round++)
        {
            var length = round % 10 == 0 ? random.Next(200, 1500) : random.Next(1, 45);
            var scale = scales[random.Next(scales.Length)];
            var invalidShare = random.Next(0, 3) switch { 0 => 0d, 1 => 0.03d, _ => 0.4d };
            var series = new double[length];
            var available = new bool[length];
            for (var row = 0; row < length; row++)
            {
                series[row] = Value(random, scale, round);
                available[row] = random.NextDouble() >= invalidShare;
            }

            var counts = RandomCounts(random, length, round % 3);
            var spanLength = random.Next(0, 4) switch { 0 => 3, 1 => 12, 2 => 70, _ => 3000 };
            var start = random.Next(-spanLength, spanLength);
            var end = start + random.Next(0, spanLength);
            var fill = random.Next(4) switch { 0 => SequenceOps.Fill, 1 => 0d, 2 => -0d, _ => 1e-310d };
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
        double[] scales = [100d, 3e-320d, 1e300d];
        for (var length = 1; length <= 70 && failures.Count < MaximumFailures; length++)
        {
            for (var segmentIndex = 0; segmentIndex < segmentLengths.Length; segmentIndex++)
            {
                var counts = new double[length];
                for (var row = 0; row < length; row++)
                    counts[row] = row % segmentLengths[segmentIndex] == 0 ? 0d : counts[row - 1] + 1d;
                for (var scaleIndex = 0; scaleIndex < scales.Length; scaleIndex++)
                {
                    var series = new double[length];
                    var available = new bool[length];
                    for (var row = 0; row < length; row++)
                    {
                        available[row] = random.NextDouble() >= 0.1d;
                        series[row] = (random.NextDouble() - 0.4d) * scales[scaleIndex];
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
        double[] specials = [0d, -0d, double.Epsilon, -double.Epsilon, 2.2250738585072009e-308d, -2.2250738585072009e-308d, 2.2250738585072014e-308d, -2.2250738585072014e-308d, limit, -limit, BitConverter.Int64BitsToDouble(BitConverter.DoubleToInt64Bits(limit) - 1L), -BitConverter.Int64BitsToDouble(BitConverter.DoubleToInt64Bits(limit) - 1L)];
        ProofParameter[] spans = [.. SequenceOps.SpanTiming, new("[-1,0]", -1d, 0d, 2d), new("[1,1]", 1d, 1d, 1d), new("[0,7]", 0d, 7d, 8d), new("[-8,-1]", -8d, -1d, 8d)];
        for (var round = 0; round < 400 && failures.Count < MaximumFailures; round++)
        {
            var length = round < 300 ? random.Next(1, 90) : 1000;
            var series = new double[length];
            var available = new bool[length];
            for (var row = 0; row < length; row++)
            {
                series[row] = random.Next(0, 4) switch
                {
                    0 => specials[random.Next(specials.Length)],
                    1 => (random.Next(2) == 0 ? 1d : -1d) * BitConverter.Int64BitsToDouble(1L + random.NextInt64((1L << 52) - 1L)),
                    2 => (random.Next(2) == 0 ? 1d : -1d) * BitConverter.Int64BitsToDouble((1L << 52) + random.NextInt64(1L << 52)),
                    _ => row > 0 && random.Next(2) == 0 ? -series[row - 1] : BitConverter.Int64BitsToDouble(random.NextInt64(1L << 53))
                };
                available[row] = round % 4 == 0 || random.NextDouble() >= 0.15d;
            }

            if (round % 5 == 0)
                series[random.Next(length)] = 1e300d;
            var counts = RandomCounts(random, length, round % 3);
            for (var index = 0; index < spans.Length && failures.Count < MaximumFailures; index++)
                Compare(string.Create(CultureInfo.InvariantCulture, $"scaled round {round} n={length} {spans[index].Label}"), series, available, counts, spans[index].First, spans[index].Second, SequenceOps.Fill, failures);
        }

        ProofBar.Fail("Scaled domain", failures);
    }

    /// <summary>Verifies the calls that are invalid as a whole: unequal lengths, a fractional or infinite offset, start above end, and a count that is negative or not an integer.</summary>
    [Fact]
    public void CallsInvalidAsAWholeStayInvalid()
    {
        var series = MathBlockValue.Vector([1d, 2d, 3d]);
        var flags = MathBlockValue.BooleanVector([true, true, true]);
        var counts = MathBlockValue.Vector([0d, 1d, 2d]);
        var form = MathBlockCudaDeviceModule.GetOperation(Form);
        var valid = MathBlockCudaDeviceModule.GetOperation(Valid);
        Assert.True(form.EvaluateCoreCLR(series, flags, counts, MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d), MathBlockValue.Scalar(-1d)).IsValid);
        MathBlockValue[][] broken =
        [
            [series, MathBlockValue.BooleanVector([true, true]), counts, MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d)],
            [series, flags, MathBlockValue.Vector([0d, 1d]), MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d)],
            [series, flags, counts, MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(1d)],
            [series, flags, counts, MathBlockValue.Scalar(0d), MathBlockValue.Scalar(double.PositiveInfinity)],
            [series, flags, counts, MathBlockValue.Scalar(2d), MathBlockValue.Scalar(1d)],
            [series, flags, MathBlockValue.Vector([0d, -1d, 2d]), MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d)],
            [series, flags, MathBlockValue.Vector([0d, 1.5d, 2d]), MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d)]
        ];
        for (var index = 0; index < broken.Length; index++)
        {
            Assert.False(valid.EvaluateCoreCLR(broken[index]).IsValid, string.Create(CultureInfo.InvariantCulture, $"validity case {index}"));
            MathBlockValue[] formInputs = [.. broken[index], MathBlockValue.Scalar(-1d)];
            Assert.False(form.EvaluateCoreCLR(formInputs).IsValid, string.Create(CultureInfo.InvariantCulture, $"form case {index}"));
        }
    }

    private static double MathBlockSimdLimit() => BitConverter.Int64BitsToDouble((long)(1023 - 900) << 52);

    // A value of the scale: ordinary random, or now and then an exact zero, a negative zero, the previous kind of edge, or a value ten magnitudes up (a large one among small ones).
    private static double Value(Random random, double scale, int round) =>
        random.Next(0, 12) switch
        {
            0 => 0d,
            1 => -0d,
            2 => scale * 1e6d * (random.NextDouble() - 0.5d),
            3 when round % 7 == 0 => scale * 1e30d * (random.NextDouble() - 0.5d),
            _ => (random.NextDouble() * 2d - 1d) * scale
        };

    // Counts of kind 0: segments cut at random zeros; 1: arbitrary non-negative integers with many zeros; 2: one segment.
    private static double[] RandomCounts(Random random, int length, int kind)
    {
        var counts = new double[length];
        for (var row = 0; row < length; row++)
        {
            counts[row] = kind switch
            {
                0 => row == 0 || random.NextDouble() < 0.1d ? 0d : counts[row - 1] + 1d,
                1 => random.NextDouble() < 0.2d ? 0d : Math.Floor(random.NextDouble() * 50d),
                _ => row
            };
        }

        return counts;
    }

    private static void Compare(string label, double[] series, bool[] available, double[] counts, double start, double end, double fill, List<string> failures)
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

        var output = new double[series.Length + 3];
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
            var expectedBits = BitConverter.DoubleToInt64Bits(expected.Values[row]);
            if (actualFlags[row] != expected.Valid[row] || BitConverter.DoubleToInt64Bits(actualValues[row]) != expectedBits || BitConverter.DoubleToInt64Bits(output[row]) != expectedBits)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: expected {expected.Values[row]:R}/{expected.Valid[row]}, actual {actualValues[row]:R}/{actualFlags[row]}, span {output[row]:R}"));
        }
    }
}
