namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies scale invariance and equivariance at extreme magnitudes, on CoreCLR with no device. Scaling an input by a power of two is exact in every
/// floating-point step, so as long as nothing overflows or underflows, f(x * 2^k) equals f(x) * 2^(d * k) bit for bit (d is 0 for a correlation or
/// a standardized value, 1 for a slope's y scale, and so on). An operation whose intermediate overflows must return an invalid value instead of a
/// finite one computed from an infinity; this is the property the zero-from-infinity defect broke.
/// </summary>
public sealed class MathBlockScaleInvarianceTests
{
    // Operation, the inputs scaled by 2^k, and the degree d.
    private static readonly Dictionary<string, (string Identity, int[] Scaled, int Degree, Func<Random, MathBlockValue[]> Inputs)> Rules =
        new(StringComparer.Ordinal)
        {
            ["pearson/x"] = ("statistics.pearson-correlation", [0], 0, Pair),
            ["pearson/y"] = ("statistics.pearson-correlation", [1], 0, Pair),
            ["pearson/both"] = ("statistics.pearson-correlation", [0, 1], 0, Pair),
            ["linear-r-squared/x"] = ("statistics.linear-r-squared", [0], 0, Pair),
            ["linear-r-squared/both"] = ("statistics.linear-r-squared", [0, 1], 0, Pair),
            ["spearman/both"] = ("statistics.spearman-correlation", [0, 1], 0, Pair),
            ["kendall/both"] = ("statistics.kendall-tau-b", [0, 1], 0, Pair),
            ["distance-correlation/x"] = ("statistics.distance-correlation", [0], 0, Pair),
            ["distance-correlation/both"] = ("statistics.distance-correlation", [0, 1], 0, Pair),
            ["autocorrelation/series"] = ("statistics.autocorrelation", [0], 0, Series),
            ["linear-slope/both"] = ("statistics.linear-slope", [0, 1], 0, Pair),
            ["linear-slope/x"] = ("statistics.linear-slope", [0], -1, Pair),
            ["linear-slope/y"] = ("statistics.linear-slope", [1], 1, Pair),
            ["linear-intercept/y"] = ("statistics.linear-intercept", [1], 1, Pair),
            ["linear-intercept/x"] = ("statistics.linear-intercept", [0], 0, Pair),
            ["standardize/series"] = ("vector.standardize", [0], 0, Single)
        };

    /// <summary>Gets the rule names.</summary>
    public static TheoryData<string> RuleNames => [.. Rules.Keys.Order(StringComparer.Ordinal)];

    /// <summary>
    /// Verifies that with all the sampled inputs, the scaled result is either invalid or exactly the scaled result, and that the
    /// moderate scales (where nothing overflows) give the exact result.
    /// </summary>
    [Theory]
    [MemberData(nameof(RuleNames))]
    public void ScalingByAPowerOfTwoGivesTheScaledResultOrAnInvalidValue(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        var (identity, scaled, degree, create) = Rules[name];
        var operation = MathBlockCatalog.Standard.Get(identity);
        var random = new Random(20261101);
        var failures = new List<string>();
        var moderate = 0;
        for (var trial = 0; trial < 60; trial++)
        {
            var inputs = create(random);
            var expected = operation.Evaluate(inputs);
            if (!expected.IsValid)
                continue;
            foreach (var k in new[] { -1000, -600, -300, -40, 40, 300, 600, 1000 })
            {
                if (!TryScale(inputs, scaled, k, out var scaledInputs) || !TryScaleScalar(ToNumbers(expected), degree * k, out var expectedScaled))
                    continue;
                var actual = operation.Evaluate(scaledInputs);
                if (Math.Abs(k) == 40)
                {
                    moderate++;
                    if (!Same(expectedScaled, actual))
                        failures.Add($"{name} trial {trial} k={k}: {Describe(actual)}, expected {string.Join(',', expectedScaled)}");
                    continue;
                }

                if (!actual.IsValid)
                    continue;
                if (!Same(expectedScaled, actual))
                    failures.Add($"{name} trial {trial} k={k}: valid {Describe(actual)}, expected {string.Join(',', expectedScaled)}");
            }
        }

        Assert.True(moderate > 20, $"Only {moderate} moderate-scale cases ran.");
        Assert.True(failures.Count == 0, $"{failures.Count} cases give a valid result that is not the scaled result; first 5:{Environment.NewLine}{string.Join(Environment.NewLine, failures.Take(5))}");
    }

    private static MathBlockValue[] Pair(Random random)
    {
        var length = 4 + random.Next(6);
        return [Draw(random, length), Draw(random, length)];
    }

    private static MathBlockValue[] Single(Random random) => [Draw(random)];

    private static MathBlockValue[] Series(Random random) => [Draw(random, 6), MathBlockValue.Scalar(1d + random.Next(2))];

    private static MathBlockValue Draw(Random random, int length = -1)
    {
        var count = length > 0 ? length : 4 + random.Next(6);
        var values = new double[count];
        for (var index = 0; index < count; index++)
            values[index] = random.Next(5) == 0 ? Math.Round((random.NextDouble() - 0.5) * 10d, MidpointRounding.ToEven) : (random.NextDouble() - 0.5) * 8d;
        return MathBlockValue.Vector(values);
    }

    private static bool TryScale(MathBlockValue[] inputs, int[] scaled, int k, out MathBlockValue[] result)
    {
        result = (MathBlockValue[])inputs.Clone();
        foreach (var index in scaled)
        {
            var source = inputs[index].AsVector().ToArray();
            var values = new double[source.Length];
            for (var item = 0; item < source.Length; item++)
            {
                if (!TryScaleOne(source[item], k, out values[item]))
                    return false;
            }

            result[index] = MathBlockValue.Vector(values);
        }

        return true;
    }

    private static bool TryScaleScalar(double[] values, double exponent, out double[] result)
    {
        result = new double[values.Length];
        for (var index = 0; index < values.Length; index++)
        {
            if (exponent != Math.Round(exponent, MidpointRounding.ToEven) || !TryScaleOne(values[index], (int)exponent, out result[index]))
                return false;
        }

        return true;
    }

    // x * 2^exponent when that is exact (no overflow, no subnormal result, no lost bits).
    private static bool TryScaleOne(double value, int exponent, out double result)
    {
        result = value;
        if (value == 0d)
            return true;
        result = Math.ScaleB(value, exponent);
        return double.IsFinite(result) && Math.Abs(result) >= double.Epsilon * 4.5035996273704960e15 && Math.ScaleB(result, -exponent) == value;
    }

    private static bool Same(double[] expected, MathBlockValue actual)
    {
        if (!actual.IsValid)
            return false;
        var values = ToNumbers(actual);
        return values.Length == expected.Length &&
            values.Zip(expected).All(pair => BitConverter.DoubleToInt64Bits(pair.First) == BitConverter.DoubleToInt64Bits(pair.Second));
    }

    private static string Describe(MathBlockValue value) =>
        value.IsValid ? string.Join(',', ToNumbers(value)) : "invalid";

    private static double[] ToNumbers(MathBlockValue value) =>
        value.Type.Kind == MathBlockValueKind.Scalar ? [value.AsScalar()] : [.. value.AsVector()];
}
