using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockCudaTranspilationTests
{
    [Fact]
    public void CUDA_scalar_unit_matches_the_published_030_golden()
    {
        var golden = File.ReadAllText(
            Path.Combine(AppContext.BaseDirectory, "Golden", "ScalarCudaBlockCatalog.cu"),
            Encoding.UTF8);
        var boundary = MathBlockCudaDeviceModule.Source.IndexOf(
            "__device__ double mathblocks_minimum",
            StringComparison.Ordinal);

        Assert.True(boundary > 0);
        var actual = MathBlockCudaDeviceModule.Source[..boundary];

        Assert.Equal(
            golden.Replace("\r\n", "\n", StringComparison.Ordinal),
            actual.Replace("\r\n", "\n", StringComparison.Ordinal));
        Assert.Equal(
            "4C1A777AC24A1A7ECF5477F021351DEA0B4205EE39EF41D293FF1645F181E35C",
            MathBlockCudaDeviceModule.SourceFingerprint);
        Assert.Equal(
            "BDEED3F33BCBE7331BBD0C04CA877D0D9F2AD6D6ADD1F2EF332ADCE2630F72DC",
            MathBlockCudaDeviceModule.Abi.OperationTableFingerprint);
    }
}
