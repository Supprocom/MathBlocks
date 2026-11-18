using System.Diagnostics;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>Times a delegate the way every proof timing test does: one warm-up call, then the median of five timed calls.</summary>
internal static class ProofTiming
{
    /// <summary>The number of timed calls.</summary>
    internal const int Samples = 5;

    /// <summary>Runs the delegate once to warm up, then five times with timing, and returns the median time per row in nanoseconds.</summary>
    internal static double NanosecondsPerRow(Action run, long rows) => NanosecondsPerRow(run, rows, Samples);

    /// <summary>Runs the delegate once to warm up, then <paramref name="samples"/> times with timing, and returns the median time per row in nanoseconds.</summary>
    internal static double NanosecondsPerRow(Action run, long rows, int samples)
    {
        run();
        var timed = new double[samples];
        for (var index = 0; index < timed.Length; index++)
        {
            var started = Stopwatch.GetTimestamp();
            run();
            timed[index] = Stopwatch.GetElapsedTime(started).TotalNanoseconds;
        }

        return Median(timed) / rows;
    }

    /// <summary>Returns the median of the values; the mean of the two middle values when their count is even.</summary>
    internal static double Median(double[] values)
    {
        var sorted = new double[values.Length];
        Array.Copy(values, sorted, values.Length);
        Array.Sort(sorted);
        return (sorted[(sorted.Length - 1) / 2] + sorted[sorted.Length / 2]) / 2d;
    }
}
