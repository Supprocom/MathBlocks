using System.Diagnostics;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>Times a delegate the way every proof timing test does: one warm-up call, then the median of five timed calls.</summary>
internal static class ProofTiming
{
    /// <summary>The number of timed calls.</summary>
    internal const int Samples = 5;

    /// <summary>Runs the delegate once to warm up, then five times with timing, and returns the median time per row in nanoseconds.</summary>
    internal static double NanosecondsPerRow(Action run, long rows)
    {
        run();
        var samples = new double[Samples];
        for (var index = 0; index < samples.Length; index++)
        {
            var started = Stopwatch.GetTimestamp();
            run();
            samples[index] = Stopwatch.GetElapsedTime(started).TotalNanoseconds;
        }

        return Median(samples) / rows;
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
