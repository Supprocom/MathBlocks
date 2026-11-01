using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

// The pair order statistics sort tens of thousands to millions of pair elements. The CUDA source orders them with the
// stable merge sort of the source's SortedCopy; an insertion sort took days at 10,233 rows and about 700 s at 1,031.
public sealed partial class MathBlockCudaWorkerTests
{
    private const int StableSortRows = 1031;

    private static readonly TimeSpan StableSortDeadline = TimeSpan.FromSeconds(20);

    /// <summary>Gets the sources of the pair order statistics test.</summary>
    public static TheoryData<string, int> PairOrderStatisticsSources => new()
    {
        { "statistics.pseudomedian", StableSortRows },
        { "statistics.theil-sen-slope", StableSortRows }
    };

    /// <summary>
    /// Verifies the pseudomedian and the Theil-Sen slope of 1,031 rows finish within 20 s on CUDA and equal the CoreCLR bits,
    /// on seeded non-dyadic values and on series of signed zeros and ties, where the stable order of equal values decides
    /// which zero a median picks. Execution is the part with the deadline; the compile is not.
    /// </summary>
    [Theory]
    [MemberData(nameof(PairOrderStatisticsSources))]
    [Trait("Category", "CudaStableSort")]
    public async Task CUDAPairOrderStatisticsFinishInTimeAndMatchCoreCLRAsync(string source, int rows)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var failures = new List<string>();
        foreach (var (name, inputs) in CreatePairOrderCases(source, rows))
        {
            var (program, _) = Standalone(source, inputs);
            var named = inputs.Select((input, index) => (Name: $"input-{index}", Input: input))
                .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
            var coreclr = program.Evaluate(named)["result"];
            // Not disposed when the deadline passes: disposing would wait for the kernel.
            var compiled = new MathBlocksCUDAWorker().Compile(program, named);
            MathBlockValue cuda;
            try
            {
                cuda = (await Task.Run(() => compiled.Execute(named)["result"]).WaitAsync(StableSortDeadline));
            }
            catch (TimeoutException)
            {
                failures.Add($"{source}/{name}: no result after {StableSortDeadline.TotalSeconds:F0} s");
                break;
            }

            compiled.Dispose();
            if (!IsExact(coreclr, cuda))
                failures.Add($"{source}/{name}: CoreCLR={DescribeBits(coreclr)}, CUDA={DescribeBits(cuda)}");
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    private static IEnumerable<(string Name, MathBlockValue[] Inputs)> CreatePairOrderCases(string source, int rows)
    {
        var random = new Random(1031);
        var pair = string.Equals(source, "statistics.theil-sen-slope", StringComparison.Ordinal);
        MathBlockValue[] Make(Func<int, double> x, Func<int, double> y) =>
            pair
                ? [MathBlockValue.Vector(Enumerable.Range(0, rows).Select(x).ToArray()), MathBlockValue.Vector(Enumerable.Range(0, rows).Select(y).ToArray())]
                : [MathBlockValue.Vector(Enumerable.Range(0, rows).Select(y).ToArray())];
        // Seeded values with no short binary expansion; x strictly increasing so no slope divides by zero.
        yield return ("random", Make(row => row + random.NextDouble() * 0.5d, _ => (random.NextDouble() * 2d - 1d) * 3.7d));
        // Mostly signed zeros and a few ones: pair averages and slopes are +0 and -0 in the thousands, so the stable order
        // of equal values decides the bits of the median.
        yield return ("signed zeros", Make(row => row, _ => random.Next(16) switch { 0 => 1d, 1 => -1d, var pick => pick % 2 == 0 ? -0d : 0d }));
        // Ties among non-zero values.
        yield return ("ties", Make(row => row * 0.25d, _ => random.Next(5) - 2d));
    }
}
