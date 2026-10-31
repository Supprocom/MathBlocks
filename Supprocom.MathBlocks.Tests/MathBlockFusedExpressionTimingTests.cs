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
    public void CoreCLRFusedAndUnfusedTimesAtFullRowCount()
    {
        foreach (var operations in new[] { 8, 32, 64 })
        {
            var random = new Random(operations);
            var program = CreateRandomProgram(random, 4, 1, 1, operations, 4);
            var fused = MathBlockFusedExpression.Create(program);
            var inputs = CreateInputs(program, FullRows, Regime.Benign, random);
            fused.EvaluateCoreCLR(inputs);
            program.Evaluate(inputs);
            const int repeats = 5;
            var watch = Stopwatch.StartNew();
            for (var repeat = 0; repeat < repeats; repeat++)
                fused.EvaluateCoreCLR(inputs);
            var fusedTime = watch.Elapsed.TotalMilliseconds / repeats;
            watch.Restart();
            for (var repeat = 0; repeat < repeats; repeat++)
                program.Evaluate(inputs);
            var unfusedTime = watch.Elapsed.TotalMilliseconds / repeats;
            output.WriteLine(
                $"{operations} operation nodes, {FullRows} rows: fused {fusedTime:F1} ms, unfused {unfusedTime:F1} ms");
        }
    }
}
