using System.Diagnostics;
using Xunit.Abstractions;
using static Supprocom.MathBlocks.Tests.MathBlockFusedTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Times the fused CoreCLR row loop against the unfused program at the full row count.</summary>
public sealed class MathBlockFusedExpressionTimingTests(ITestOutputHelper output)
{
    /// <summary>Reports fused and unfused CoreCLR times for programs of 8, 32 and 64 operation nodes.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void CoreCLRFusedAndUnfusedTimesAtFullRowCount() => Time(0);

    /// <summary>
    /// Reports fused and unfused CoreCLR times for programs of 8, 32 and 64 operation nodes of which about half are
    /// elementwise forms and siblings.
    /// </summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void CoreCLRFusedAndUnfusedTimesWithElementwiseFormsAtFullRowCount() => Time(50);

    private void Time(int elementwisePercent)
    {
        foreach (var operations in new[] { 8, 32, 64 })
        {
            var random = new Random(operations + elementwisePercent);
            var program = CreateRandomProgram(random, 4, 1, 1, operations, 4, elementwisePercent);
            var fused = MathBlockFusedExpression.Create(program);
            var inputs = CreateInputs(program, FullRows, Regime.Benign, random);
            fused.EvaluateCoreCLR(inputs);
            program.Evaluate(inputs);
            // Fused and unfused alternate per repeat, so host load affects both sides alike.
            const int repeats = 5;
            var fusedTimes = new double[repeats];
            var unfusedTimes = new double[repeats];
            for (var repeat = 0; repeat < repeats; repeat++)
            {
                var watch = Stopwatch.StartNew();
                fused.EvaluateCoreCLR(inputs);
                fusedTimes[repeat] = watch.Elapsed.TotalMilliseconds;
                watch.Restart();
                program.Evaluate(inputs);
                unfusedTimes[repeat] = watch.Elapsed.TotalMilliseconds;
            }
            var ratios = fusedTimes.Zip(unfusedTimes, (left, right) => left / right).ToArray();
            var elementwise = program.PlanNodes.Count(node =>
                node.OperationIdentity?.StartsWith("elementwise", StringComparison.Ordinal) == true);
            output.WriteLine($"{operations} operation nodes ({elementwise} elementwise), {FullRows} rows, {repeats} repeats");
            output.WriteLine($"  fused ms: {Spread(fusedTimes)}");
            output.WriteLine($"  unfused ms: {Spread(unfusedTimes)}");
            output.WriteLine($"  fused / unfused, per repeat: {Spread(ratios)}");
        }
    }

    private static string Spread(double[] values)
    {
        var sorted = values.Order().ToArray();
        var median = (sorted[(sorted.Length - 1) / 2] + sorted[sorted.Length / 2]) / 2d;
        return string.Create(
            System.Globalization.CultureInfo.InvariantCulture,
            $"min {sorted[0]:F3}, median {median:F3}, max {sorted[^1]:F3}");
    }
}
