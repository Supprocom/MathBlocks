using static Supprocom.MathBlocks.Tests.MathBlockWindowM2TestSupport;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies the M2 monotone-deque and sliding order-statistic paths of the window.vector minimum, maximum,
/// arg-minimum, arg-maximum, median and quantile forms against the direct M1 lift, bit for bit.
/// </summary>
public sealed class MathBlockWindowFastPathTests
{
    private const float Sentinel = 4_321.75f;

    private static readonly int[] Widths = [1, 2, 3, 4, 5, 7, 17, 96];

    private static readonly float[] Probabilities = [0f, -0f, 0.1f, 0.25f, 0.3f, 0.5f, 0.75f, 0.9f, 1f, 1.5f];

    /// <summary>Gets the sources whose window forms have an M2 kernel.</summary>
    public static TheoryData<string> Sources => [.. KernelSources];

    /// <summary>
    /// Verifies every row equals the direct lift bit for bit, including the signed zero chosen and the tie position,
    /// on series with signed zeros, ties, constant runs and monotone runs.
    /// </summary>
    [Theory]
    [MemberData(nameof(Sources))]
    public void RowsEqualTheDirectLiftBitForBit(string source)
    {
        var failures = new List<string>();
        foreach (var (name, series) in CreateSeries(1_200, 20_261_031))
        {
            foreach (var width in Widths)
            {
                if (width > series.Length)
                    continue;
                foreach (var parameters in Parameters(source))
                    failures.AddRange(Compare(source, name, series, width, parameters));
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(40)));
    }

    /// <summary>Verifies the extreme forms choose -0 or +0 and the tie position exactly as their sources do.</summary>
    [Fact]
    public void SignedZerosAndTiesFollowTheSourceRules()
    {
        var x = MathBlockValue.Vector([0f, -0f, 0f, 1f, -0f, 1f, 1f, -1f, -1f]);
        var width = MathBlockValue.Scalar(3f);
        var fill = MathBlockValue.Scalar(Sentinel);

        var minimum = Form("vector.minimum").Evaluate(x, width, fill).AsVector().ToArray();
        var maximum = Form("vector.maximum").Evaluate(x, width, fill).AsVector().ToArray();
        var argMinimum = Form("vector.arg-minimum").Evaluate(x, width, fill).AsVector().ToArray();
        var argMaximum = Form("vector.arg-maximum").Evaluate(x, width, fill).AsVector().ToArray();
        var median = Form("vector.median").Evaluate(x, width, fill).AsVector().ToArray();

        // Math.Min prefers -0 and Math.Max +0 among equal zeros.
        Assert.Equal(
            new[] { Sentinel, Sentinel, -0f, -0f, -0f, -0f, -0f, -1f, -1f }.Select(BitConverter.SingleToInt32Bits),
            minimum.Select(BitConverter.SingleToInt32Bits));
        Assert.Equal(
            new[] { Sentinel, Sentinel, 0f, 1f, 1f, 1f, 1f, 1f, 1f }.Select(BitConverter.SingleToInt32Bits),
            maximum.Select(BitConverter.SingleToInt32Bits));
        // The first strictly lower (higher) value wins; -0 and +0 compare equal.
        Assert.Equal([Sentinel, Sentinel, 0f, 0f, 0f, 1f, 0f, 2f, 1f], argMinimum);
        Assert.Equal([Sentinel, Sentinel, 0f, 2f, 1f, 0f, 1f, 0f, 0f], argMaximum);
        // The stable sort keeps equal zeros in window order, so the middle element's sign is the later zero's.
        Assert.Equal(
            new[] { Sentinel, Sentinel, -0f, 0f, -0f, 1f, 1f, 1f, -1f }.Select(BitConverter.SingleToInt32Bits),
            median.Select(BitConverter.SingleToInt32Bits));
        foreach (var source in new[] { "vector.minimum", "vector.maximum", "vector.arg-minimum", "vector.arg-maximum", "vector.median" })
        {
            var difference = Difference(DirectForm(source).Evaluate(x, width, fill), Form(source).Evaluate(x, width, fill));
            Assert.True(difference is null, $"{source}: {difference}");
        }
    }

    /// <summary>Verifies an out-of-domain quantile probability fills every row and marks it not computed.</summary>
    [Fact]
    public void OutOfDomainProbabilitiesFillEveryRow()
    {
        var x = MathBlockValue.Vector([3f, 1f, 2f, 5f]);
        foreach (var probability in new[] { -0.25f, 1.5f })
        {
            var p = MathBlockValue.Scalar(probability);
            var form = Form("vector.quantile").Evaluate(x, p, MathBlockValue.Scalar(2f), MathBlockValue.Scalar(Sentinel));
            var validity = Validity("vector.quantile").Evaluate(x, p, MathBlockValue.Scalar(2f));

            Assert.Equal([Sentinel, Sentinel, Sentinel, Sentinel], form.AsVector().ToArray());
            Assert.Equal([false, false, false, false], validity.AsBooleanVector().ToArray());
        }
    }

    internal static IEnumerable<float[]> Parameters(string source) =>
        string.Equals(source, "vector.quantile", StringComparison.Ordinal)
            ? Probabilities.Select(probability => new[] { probability })
            : [[]];

    // Compares the kernel form and sibling with the direct-lift form and sibling, with a sentinel fill and with a fill
    // that also occurs as a computed value.
    internal static List<string> Compare(string source, string name, float[] series, int width, float[] parameters)
    {
        var failures = new List<string>();
        var x = MathBlockValue.Vector(series);
        MathBlockValue[] sourceInputs = [x, .. parameters.Select(parameter => MathBlockValue.Scalar(parameter))];
        foreach (var fill in new[] { Sentinel, series[^1] })
        {
            var formInputs = FormInputs(sourceInputs, width, MathBlockValue.Scalar(fill));
            var where = $"{source} {name} w={width} p=[{string.Join(',', parameters)}] fill={fill}";
            var form = Difference(DirectForm(source).Evaluate(formInputs), Form(source).Evaluate(formInputs));
            if (form is not null)
                failures.Add($"{where}: form {form}");
        }
        var validityInputs = ValidityInputs(sourceInputs, width);
        var validity = Difference(DirectValidity(source).Evaluate(validityInputs), Validity(source).Evaluate(validityInputs));
        if (validity is not null)
            failures.Add($"{source} {name} w={width}: sibling {validity}");
        return failures;
    }

    // Series that exercise the deque and heap tie rules: signed zeros, values from a small set, constant runs,
    // increasing and decreasing runs, and plain random values.
    internal static IEnumerable<(string Name, float[] Series)> CreateSeries(int count, int seed)
    {
        var random = new Random(seed);
        float[] small = [-2f, -1f, -0f, 0f, 1f, 2f];
        var ties = new float[count];
        for (var row = 0; row < count; row++)
            ties[row] = small[random.Next(small.Length)];
        yield return ("ties", ties);

        var zeros = new float[count];
        for (var row = 0; row < count; row++)
            zeros[row] = random.Next(2) == 0 ? -0f : 0f;
        yield return ("signed-zeros", zeros);

        var constant = new float[count];
        Array.Fill(constant, 1.25f);
        yield return ("constant", constant);

        var mixed = new float[count];
        for (var row = 0; row < count; row++)
        {
            mixed[row] = (row / 150 % 4) switch
            {
                0 => random.NextSingle() * 2f - 1f,
                1 => row % 150,
                2 => -(row % 150),
                _ => row % 7 == 0 ? -0f : 0.5f
            };
        }
        yield return ("runs", mixed);

        var plain = new float[count];
        for (var row = 0; row < count; row++)
            plain[row] = random.NextSingle() * 200f - 100f;
        yield return ("random", plain);
    }
}
