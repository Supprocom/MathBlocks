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

    // Pairs (n, k) whose product loop overflows although C(n, k) fits in a single, then pairs whose value is above the largest single, then the pairs next to them.
    private static readonly (int N, int K)[] Pairs =
    [
        (129, 64), (131, 65), (130, 65), (128, 64), (127, 63), (131, 66), (1000000, 7), (1000000, 999993), (1000000, 8), (200, 100), (500, 60), (132, 66),
        (130, 60), (1000000, 6), (2147483647, 4), (2147483647, 600)
    ];

    private static (float[] First, float[] Second) Rows(bool ballot)
    {
        var first = new List<float>();
        var second = new List<float>();
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
        var (program, inputs) = MathBlockCudaDomainDeviceTests.Build(identity, [MathBlockValue.Vector(first), MathBlockValue.Vector(second), MathBlockValue.Scalar(-1f)]);

        var coreclr = MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"];
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs);
        var cuda = compiled.Execute(inputs)["result"];

        Assert.True(MathBlockDomainWiringTests.Same(coreclr, cuda), $"{identity}: the device differs from CoreCLR.");
        Assert.True(coreclr.IsValid);
        var values = coreclr.AsVector();
        // The ballot count of the first pair is its coefficient divided by 129, so the bar is below both.
        Assert.True(float.IsFinite(values[0]) && values[0] > 1e35f, "The row of (129, 64) is not the finite coefficient.");
        Assert.True(float.IsFinite(values[6]) && values[6] > 1e35f, "The row of (1000000, 7) is not the finite coefficient.");
    }
}
