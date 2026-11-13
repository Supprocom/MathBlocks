using System.Reflection;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains the test of the largest window width of the scratch-limited forms, which the plan message and the limit catalog both state.</summary>
public sealed class MathBlockWindowMaximumWidthTests
{
    /// <summary>Verifies theil-sen-slope, whose scratch is 0 at width 1 and quadratic above it, has a real width limit and the catalog record agrees.</summary>
    [Fact]
    public void ATheilSenWidthLimitComesFromItsQuadraticScratch()
    {
        var catalog = typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.WindowCudaBlockCatalog", throwOnError: true)!;
        var maximumWidth = catalog.GetMethod("MaximumWidth", BindingFlags.Static | BindingFlags.NonPublic, [typeof(int), typeof(int)])!;
        var scratch = catalog.GetMethod("ScratchDoubles", BindingFlags.Static | BindingFlags.NonPublic)!;

        var width = (long)maximumWidth.Invoke(null, [22, 128])!;

        Assert.InRange(width, 1_000L, 2_000L);
        var limit = int.MaxValue / (8L * 128L);
        Assert.True((long)scratch.Invoke(null, [22, width])! <= limit);
        Assert.True((long)scratch.Invoke(null, [22, width + 1])! > limit);
        var record = MathBlockLimits.Resolve().Single(candidate =>
            string.Equals(candidate.Name, "cuda.window.maximum-width", StringComparison.Ordinal) &&
            string.Equals(candidate.Operation, "window.statistics.theil-sen-slope@1", StringComparison.Ordinal));
        Assert.Equal(width, record.Value);
        Assert.Equal(MathBlockLimitKind.Derived, record.Kind);
        Assert.Equal((long)int.MaxValue, (long)maximumWidth.Invoke(null, [0, 128])!);
    }
}
