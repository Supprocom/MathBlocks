using System.Diagnostics;
using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the CUDA device tests of the binomial table: the ballot count and the binomial coefficient give the CoreCLR bits on a cold table and on a warm one, and the
/// time of a million trade-count-like rows on each. They need a CUDA device and are excluded from the device-free runs.
/// </summary>
public sealed class MathBlockBinomialTableDeviceTests
{
    private const string BallotCount = "elementwise.combinatorics.ballot-count@1";
    private const string BinomialCoefficient = "elementwise.combinatorics.binomial-coefficient@1";

    // Pairs (a, b) for the first operand and the second: trade-count-like rows with a + b in 100..1000 and a > b, the edges of the table (a + b from 1020 to 1026
    // with every b), and rows outside the table or the domain.
    private static (double[] First, double[] Second) Rows(int tradeLikeRows)
    {
        var first = new List<double>(tradeLikeRows + 8_000);
        var second = new List<double>(tradeLikeRows + 8_000);
        var state = 0x2545F4914F6CDD1DUL;
        for (var row = 0; row < tradeLikeRows; row++)
        {
            state = (state * 6364136223846793005UL) + 1442695040888963407UL;
            var sum = 100 + (int)((state >> 33) % 901UL);
            state = (state * 6364136223846793005UL) + 1442695040888963407UL;
            var trailing = (int)((state >> 33) % (ulong)(((sum - 1) / 2) + 1));
            first.Add(sum - trailing);
            second.Add(trailing);
        }

        for (var sum = 1020; sum <= 1026; sum++)
        {
            for (var trailing = -2; trailing <= sum + 2; trailing++)
            {
                first.Add(sum - trailing);
                second.Add(trailing);
            }
        }

        double[] specials = [0.5, -1d, 2147483647d, 1e10, double.NaN, double.PositiveInfinity, 3000d, 1500d, 1023d, 1024d, 0d, 7d];
        for (var left = 0; left < specials.Length; left++)
        {
            for (var right = 0; right < specials.Length; right++)
            {
                first.Add(specials[left]);
                second.Add(specials[right]);
            }
        }

        return (first.ToArray(), second.ToArray());
    }

    private static (MathBlockProgram Program, Dictionary<string, MathBlockValue> Inputs) Build(string identity, double[] first, double[] second) =>
        MathBlockCudaDomainDeviceTests.Build(identity, [MathBlockValue.Vector(first), MathBlockValue.Vector(second), MathBlockValue.Scalar(-1d)]);

    /// <summary>Verifies the ballot count and the binomial coefficient give the CoreCLR bits on the first execution, with the table empty, and on the executions after it, with the table filled.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [InlineData(BallotCount)]
    [InlineData(BinomialCoefficient)]
    public void CUDAMatchesCoreCLROnAColdAndOnAWarmTable(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (first, second) = Rows(20_000);
        var (program, inputs) = Build(identity, first, second);

        var coreclr = MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"];
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs);
        var cold = compiled.Execute(inputs)["result"];
        var warm = compiled.Execute(inputs)["result"];
        var warmAgain = compiled.Execute(inputs)["result"];

        Assert.True(MathBlockDomainWiringTests.Same(coreclr, cold), $"{identity}: the cold table differs from CoreCLR.");
        Assert.True(MathBlockDomainWiringTests.Same(coreclr, warm), $"{identity}: the warm table differs from CoreCLR.");
        Assert.True(MathBlockDomainWiringTests.Same(coreclr, warmAgain), $"{identity}: the third execution differs from CoreCLR.");
    }

    /// <summary>Measures a million trade-count-like rows of the ballot count on a cold table and on a warm one, checks the bits against CoreCLR and prints the times.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void CUDATimesAMillionTradeCountRowsOnAColdAndOnAWarmTable()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (first, second) = Rows(1_000_000);
        var (program, inputs) = Build(BallotCount, first, second);
        var coreclr = MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"];
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs);

        var started = Stopwatch.GetTimestamp();
        var cold = compiled.Execute(inputs)["result"];
        var coldMilliseconds = Stopwatch.GetElapsedTime(started).TotalMilliseconds;
        var warmMilliseconds = double.MaxValue;
        var warm = cold;
        for (var pass = 0; pass < 3; pass++)
        {
            started = Stopwatch.GetTimestamp();
            warm = compiled.Execute(inputs)["result"];
            warmMilliseconds = Math.Min(warmMilliseconds, Stopwatch.GetElapsedTime(started).TotalMilliseconds);
        }

        Assert.True(MathBlockDomainWiringTests.Same(coreclr, cold));
        Assert.True(MathBlockDomainWiringTests.Same(coreclr, warm));
        Console.WriteLine(string.Create(
            CultureInfo.InvariantCulture,
            $"Ballot count of {first.Length} rows on the device, including the transfers: cold table {coldMilliseconds:F1} ms, warm table best of 3 {warmMilliseconds:F1} ms."));
    }
}
