using System.Diagnostics;
using System.Globalization;
using System.Text;
using Xunit.Abstractions;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Times the CoreCLR sine, cosine and tangent per row over classes of arguments, against the implementation of 0.8.0-local.2.</summary>
public sealed class MathBlockTrigonometricTimingTests(ITestOutputHelper output)
{
    private const int Rows = 1 << 20;
    private const int Repeats = 7;

    /// <summary>
    /// Reports the nanoseconds per row of the new and the old sine, cosine and tangent over the classes typical (|x| &lt; 10), large (1e3 to 1e6),
    /// near-bound (2^23 to 2^24), out-of-domain (above 2^24) and a mixed series, and asserts the worst in-domain class of the new implementation is at
    /// most twice the median class: the cost is flat in |x|. Writes a tab-separated table to the path in MATHBLOCKS_TRIG_TIMING_TSV when it is set.
    /// The numbers are indicative on a loaded machine.
    /// </summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void NewTrigonometricCostIsFlatInTheArgument()
    {
        var random = new Random(20_261_129);
        float Draw(double low, double high, bool logarithmic)
        {
            var magnitude = logarithmic ? Math.Pow(10, low + random.NextDouble() * (high - low)) : low + random.NextDouble() * (high - low);
            return (float)(random.Next(2) == 0 ? magnitude : -magnitude);
        }

        var classes = new (string Name, bool InDomain, float[] Values)[]
        {
            ("typical", true, Enumerable.Range(0, Rows).Select(_ => Draw(0, 10, false)).ToArray()),
            ("large", true, Enumerable.Range(0, Rows).Select(_ => Draw(3, 6, true)).ToArray()),
            ("near-bound", true, Enumerable.Range(0, Rows).Select(_ => Draw(8_388_608, 16_777_216, false)).ToArray()),
            ("out-of-domain", false, Enumerable.Range(0, Rows).Select(_ => Draw(7.3, 38, true)).ToArray()),
        };
        var mixed = new float[Rows];
        for (var index = 0; index < Rows; index++)
            mixed[index] = classes[random.Next(classes.Length)].Values[index];
        classes = [.. classes, ("mixed", false, mixed)];

        var table = new StringBuilder("function\tclass\tnew_ns_per_row\told_ns_per_row\n");
        foreach (var (function, newFunction, oldFunction) in new (string, Func<float, float>, Func<float, float>)[]
                 {
                     ("sine", MathBlockScalar.Sine, MathBlockTrigonometricOldOracle.Sine),
                     ("cosine", MathBlockScalar.Cosine, MathBlockTrigonometricOldOracle.Cosine),
                     ("tangent", MathBlockScalar.Tangent, MathBlockTrigonometricOldOracle.Tangent)
                 })
        {
            var newTimes = new List<(string Name, bool InDomain, double Nanoseconds)>();
            foreach (var (name, inDomain, values) in classes)
            {
                var current = Measure(newFunction, values);
                var old = Measure(oldFunction, values);
                newTimes.Add((name, inDomain, current));
                table.Append(CultureInfo.InvariantCulture, $"{function}\t{name}\t{current:F2}\t{old:F2}\n");
                output.WriteLine($"{function,-8} {name,-14} new {current,7:F2} ns   old {old,7:F2} ns");
            }

            var median = newTimes.Select(item => item.Nanoseconds).Order().ElementAt(newTimes.Count / 2);
            var worst = newTimes.Where(item => item.InDomain).Max(item => item.Nanoseconds);
            output.WriteLine($"{function}: worst in-domain class {worst:F2} ns, median class {median:F2} ns, ratio {worst / median:F2}");
            table.Append(CultureInfo.InvariantCulture, $"{function}\tworst-in-domain/median\t{worst / median:F3}\t\n");
            Assert.True(worst <= 2 * median, $"{function}: worst in-domain class {worst:F2} ns exceeds twice the median class {median:F2} ns.");
        }

        var path = Environment.GetEnvironmentVariable("MATHBLOCKS_TRIG_TIMING_TSV");
        if (!string.IsNullOrEmpty(path))
            File.WriteAllText(path, table.ToString());
    }

    private static double Measure(Func<float, float> function, float[] values)
    {
        var best = double.MaxValue;
        var sink = 0;
        for (var repeat = 0; repeat < Repeats + 1; repeat++)
        {
            var started = Stopwatch.GetTimestamp();
            for (var index = 0; index < values.Length; index++)
                sink ^= BitConverter.SingleToInt32Bits(function(values[index]));
            var elapsed = Stopwatch.GetElapsedTime(started).TotalNanoseconds / values.Length;
            if (repeat > 0)
                best = Math.Min(best, elapsed);
        }

        GC.KeepAlive(sink);
        return best;
    }
}
