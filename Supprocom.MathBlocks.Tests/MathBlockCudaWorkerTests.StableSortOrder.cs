using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

// The operations that order a whole vector, point set or edge list took the insertion sort of the first CUDA source: at the
// length of the BTC series (302,893 rows) about 230 s for the Lorenz curve and 460 s for the weighted Wasserstein distance.
// Each case runs the operation on CUDA with a deadline on the execution and compares the bits with CoreCLR, on inputs full of
// ties and signed zeros, where the stable order decides which of equal values comes first.
public sealed partial class MathBlockCudaWorkerTests
{
    private const int BitcoinRows = 302_893;

    /// <summary>Gets the operations of the whole-input sort test.</summary>
    public static TheoryData<string> WholeInputSortSources =>
    [
        "inequality.lorenz-curve",
        "transport.weighted-wasserstein-1",
        "geometry.convex-hull",
        "topology.zero-dimensional-persistence",
        "graph.minimum-spanning-forest"
    ];

    /// <summary>
    /// Verifies the Lorenz curve and the weighted Wasserstein distance of 302,893 rows, the convex hull of 302,893 points, the
    /// zero-dimensional persistence of 2,000 points (1,999,000 edges) and the minimum spanning forest of 302,893 edges finish
    /// within 20 s on CUDA and equal the CoreCLR bits. The persistence is smaller because its edge list grows with the square
    /// of the points: at the 11,585 points the scratch allows, the merge sort of 67 million edges alone takes about 15 s.
    /// </summary>
    [Theory]
    [MemberData(nameof(WholeInputSortSources))]
    [Trait("Category", "CudaStableSort")]
    public async Task CUDAWholeInputSortsFinishInTimeAndMatchCoreCLRAsync(string source)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var inputs = CreateWholeInputSortInputs(source);
        var (program, _) = Standalone(source, inputs);
        var named = inputs.Select((input, index) => (Name: $"input-{index}", Input: input))
            .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
        var coreclr = program.Evaluate(named)["result"];
        // Not disposed when the deadline passes: disposing would wait for the kernel.
        var compiled = new MathBlocksCUDAWorker().Compile(program, named);
        MathBlockValue cuda;
        try
        {
            cuda = await Task.Run(() => compiled.Execute(named)["result"]).WaitAsync(StableSortDeadline);
        }
        catch (TimeoutException)
        {
            Assert.Fail($"{source}: no result after {StableSortDeadline.TotalSeconds:F0} s");
            return;
        }

        compiled.Dispose();
        Assert.True(IsExact(coreclr, cuda), $"{source}: CoreCLR={DescribeBits(coreclr)}, CUDA={DescribeBits(cuda)}");
    }

    private static MathBlockValue[] CreateWholeInputSortInputs(string source)
    {
        var random = new Random(302_893);
        // Few distinct values, so most pairs tie, plus both signed zeros.
        double Tied() => random.Next(12) switch { 0 => -0d, 1 => 0d, var pick => (pick - 6) * 0.5d };
        MathBlockValue Weights(int count)
        {
            var raw = Enumerable.Range(0, count).Select(_ => 1d + random.Next(7)).ToArray();
            var total = raw.Sum();
            return MathBlockValue.Vector(raw.Select(value => value / total).ToArray());
        }

        // One point in ten from the tied pool (duplicates, signed zeros, collinear points), the rest distinct: the old sorted
        // insertion of the points costs a move for every smaller point already inserted.
        double HullCoordinate(int index) => index % 10 == 0 ? Tied() : (random.NextDouble() * 2d - 1d) * 4d;

        switch (source)
        {
            case "inequality.lorenz-curve":
                return [MathBlockValue.Vector(Enumerable.Range(0, BitcoinRows).Select(_ => Math.Abs(Tied())).ToArray())];
            case "transport.weighted-wasserstein-1":
                return
                [
                    MathBlockValue.Vector(Enumerable.Range(0, BitcoinRows).Select(_ => Tied()).ToArray()), Weights(BitcoinRows),
                    MathBlockValue.Vector(Enumerable.Range(0, BitcoinRows).Select(_ => Tied()).ToArray()), Weights(BitcoinRows)
                ];
            case "geometry.convex-hull":
                return [MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Range(0, BitcoinRows).Select(index => new MathBlockPoint(HullCoordinate(index), HullCoordinate(index))).ToArray()))];
            case "topology.zero-dimensional-persistence":
                return [MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Range(0, 2_000).Select(_ => new MathBlockPoint(Tied() + random.NextDouble() * 1e-3d, Tied())).ToArray()))];
            case "graph.minimum-spanning-forest":
                const int vertices = 5_000;
                return
                [
                    MathBlockValue.Graph(new MathBlockGraph(
                        vertices,
                        Enumerable.Range(0, BitcoinRows).Select(_ =>
                        {
                            var from = random.Next(vertices);
                            return new MathBlockGraphEdge(from, (from + 1 + random.Next(vertices - 1)) % vertices, Tied());
                        }).ToArray()))
                ];
            default:
                throw new ArgumentOutOfRangeException(nameof(source), source, "Unknown source.");
        }
    }
}
