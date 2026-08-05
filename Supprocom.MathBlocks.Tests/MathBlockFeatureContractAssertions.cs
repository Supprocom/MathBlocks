using System.Diagnostics;

namespace Supprocom.MathBlocks.Tests;

internal static class MathBlockFeatureContractAssertions
{
    public static void Verify(string identity)
    {
        var separator = identity.LastIndexOf('@');
        Assert.True(separator > 0, $"Identity '{identity}' has no version.");
        var operation = MathBlockCatalog.Standard.Get(
            identity[..separator],
            int.Parse(identity[(separator + 1)..], System.Globalization.CultureInfo.InvariantCulture));

        Assert.Equal(identity, operation.Identity);
        Assert.NotEmpty(operation.RegressionCases);
        Assert.NotEmpty(operation.PerformanceCase.Inputs);
        Assert.InRange(operation.PerformanceCase.MaximumWarmLatencyMicroseconds, double.Epsilon, 1_000d);
        Assert.Equal(operation.Arity, operation.PerformanceCase.Inputs.Count);
        Assert.Contains(identity, Cuda.MathBlocksCUDAWorker.SupportedBlockIdentities);

        foreach (var regression in operation.RegressionCases)
        {
            var actual = operation.Evaluate(regression.Inputs);
            Assert.True(
                actual.ApproximatelyEquals(regression.Expected, regression.Tolerance),
                $"{identity}/{regression.Name} did not match its regression result.");
        }

        for (var warmup = 0; warmup < 64; warmup++)
            _ = operation.Evaluate(operation.PerformanceCase.Inputs);

        const int batchCount = 101;
        var samples = new double[batchCount];
        for (var batch = 0; batch < batchCount; batch++)
        {
            var started = Stopwatch.GetTimestamp();
            for (var iteration = 0; iteration < operation.PerformanceCase.Iterations; iteration++)
                _ = operation.Evaluate(operation.PerformanceCase.Inputs);
            samples[batch] = Stopwatch.GetElapsedTime(started).TotalMilliseconds * 1_000d /
                             operation.PerformanceCase.Iterations;
        }
        Array.Sort(samples);
        var warmP95 = samples[95];
        Assert.True(
            warmP95 < operation.PerformanceCase.MaximumWarmLatencyMicroseconds,
            $"{identity} warm p95 was {warmP95:F3} microseconds.");
    }
}
