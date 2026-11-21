using System.Diagnostics;
using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// Times a delegate the way every proof timing test does: one warm-up call, then the median of the timed calls. An evaluation writes its result into a new array, and two things that the
/// operation does not decide can then fall into a timed call: when the runtime places the array on memory it has just mapped again, the system takes a page fault for every page of it
/// (about three nanoseconds per row), and when the allocation is the one that starts a collection, the call waits for it (about four nanoseconds per row). A cell and its reference take
/// or miss both independently, and either is as large as the operations that are timed. A timed call that took such page faults or a collection is therefore not a sample; the call is
/// repeated, up to eight times the number of samples. A delegate that takes them on nearly every call keeps them: its median is then over all of its calls. Where the system does not
/// report the page faults of the process (they are read from /proc/self/stat), only the collections are told apart.
/// </summary>
internal static class ProofTiming
{
    /// <summary>The number of timed calls.</summary>
    internal const int Samples = 5;

    // A call that took more page faults than a quarter of the pages of one result of its rows (eight bytes per row, 4096 bytes per page) wrote to newly mapped memory.
    private const long RowsPerAllowedFault = 2048;

    private const int TriesPerSample = 8;

    /// <summary>Runs the delegate once to warm up, then five times with timing, and returns the median time per row in nanoseconds.</summary>
    internal static double NanosecondsPerRow(Action run, long rows) => NanosecondsPerRow(run, rows, Samples);

    /// <summary>
    /// Runs the delegate once to warm up, then with timing until <paramref name="samples"/> calls took neither page faults for newly mapped memory nor a collection, and returns their
    /// median time per row in nanoseconds; after eight times that many calls without enough of them, the median of all the calls.
    /// </summary>
    internal static double NanosecondsPerRow(Action run, long rows, int samples)
    {
        run();
        var allowed = rows / RowsPerAllowedFault;
        var settled = new List<double>(samples);
        var all = new List<double>(samples);
        while (settled.Count < samples && all.Count < TriesPerSample * samples)
        {
            var faults = MinorPageFaults();
            var collections = GC.CollectionCount(0);
            var started = Stopwatch.GetTimestamp();
            run();
            var elapsed = Stopwatch.GetElapsedTime(started).TotalNanoseconds;
            all.Add(elapsed);
            // A collection of any generation counts as one of generation 0.
            if (GC.CollectionCount(0) == collections && MinorPageFaults() - faults <= allowed)
                settled.Add(elapsed);
        }

        return Median((settled.Count == samples ? settled : all).ToArray()) / rows;
    }

    /// <summary>Returns the median of the values; the mean of the two middle values when their count is even.</summary>
    internal static double Median(double[] values)
    {
        var sorted = new double[values.Length];
        Array.Copy(values, sorted, values.Length);
        Array.Sort(sorted);
        return (sorted[(sorted.Length - 1) / 2] + sorted[sorted.Length / 2]) / 2d;
    }

    // The minor page faults of the process so far (the tenth field of /proc/self/stat, the eighth after the command name), or zero where the system has no such file.
    private static long MinorPageFaults()
    {
        try
        {
            var text = File.ReadAllText("/proc/self/stat");
            var fields = text[(text.LastIndexOf(')') + 2)..].Split(' ');
            return long.Parse(fields[7], CultureInfo.InvariantCulture);
        }
        catch (Exception exception) when (exception is IOException or UnauthorizedAccessException or FormatException or IndexOutOfRangeException or ArgumentOutOfRangeException)
        {
            return 0L;
        }
    }
}
