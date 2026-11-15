using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the CUDA device tests of the binomial coefficient where the product loop overflows although C(n, k) fits in a double: the binomial coefficient and the ballot
/// count give the CoreCLR bits, and the rows are valid. They need a CUDA device and are excluded from the device-free runs.
/// </summary>
public sealed class MathBlockBinomialOverflowDeviceTests
{
    private const string BallotCount = "elementwise.combinatorics.ballot-count@1";
    private const string BinomialCoefficient = "elementwise.combinatorics.binomial-coefficient@1";

    // Pairs (n, k) whose product loop overflows although C(n, k) fits in a double, then pairs whose value is above the largest double, then the pairs next to them.
    private static readonly (int N, int K)[] Pairs =
    [
        (1023, 511), (1023, 500), (1022, 511), (1021, 496), (1024, 477), (1115, 372), (1000000, 67), (1000000, 999933), (1000000, 68), (1500, 700), (5000, 600), (1030, 515),
        (1023, 450), (1000000, 66), (2147483647, 33), (2147483647, 600)
    ];

    private static (double[] First, double[] Second) Rows(bool ballot)
    {
        var first = new List<double>();
        var second = new List<double>();
        for (var pair = 0; pair < Pairs.Length; pair++)
        {
            var (n, k) = Pairs[pair];
            first.Add(ballot ? n - k : n);
            second.Add(k);
        }

        for (var k = 480; k <= 512; k++)
        {
            first.Add(ballot ? 1023 - k : 1023);
            second.Add(k);
        }

        return (first.ToArray(), second.ToArray());
    }

    /// <summary>Verifies the device gives the CoreCLR bits for the binomial coefficient and the ballot count on the pairs the product loop overflowed on, and that the rows of the fixed pairs are valid.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [InlineData(BallotCount)]
    [InlineData(BinomialCoefficient)]
    public void CUDAMatchesCoreCLROnPairsWhoseProductOverflowed(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (first, second) = Rows(string.Equals(identity, BallotCount, StringComparison.Ordinal));
        var (program, inputs) = MathBlockCudaDomainDeviceTests.Build(identity, [MathBlockValue.Vector(first), MathBlockValue.Vector(second), MathBlockValue.Scalar(-1d)]);

        var coreclr = MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"];
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs);
        var cuda = compiled.Execute(inputs)["result"];

        Assert.True(MathBlockDomainWiringTests.Same(coreclr, cuda), $"{identity}: the device differs from CoreCLR.");
        Assert.True(coreclr.IsValid);
        var values = coreclr.AsVector();
        Assert.True(values[0] > 1e300, "The row of (1023, 511) is not the finite coefficient.");
        Assert.True(values[6] > 1e300, "The row of (1000000, 67) is not the finite coefficient.");
    }
}
