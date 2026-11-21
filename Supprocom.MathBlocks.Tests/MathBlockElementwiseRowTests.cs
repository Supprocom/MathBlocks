using System.Reflection;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the NVRTC tests of the single-row elementwise device function <c>mathblocks_elementwise_row</c>, which need NVRTC and no CUDA device:
/// the module source carries the declaration <see cref="MathBlockCudaDeviceModule.ElementwiseRowSignature"/> publishes, and a consumer-owned
/// kernel that calls the function compiles after the device source of the defaults and of a configured domain.
/// </summary>
public sealed class MathBlockElementwiseRowTests
{
    private const string Architecture = "compute_86";

    private static readonly MethodInfo Compile = typeof(MathBlockCatalog).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
        .GetMethod(
            "CompilePtxWithoutDevice",
            BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public,
            [typeof(string), typeof(string), typeof(string)])!;

    // NVRTC ignores source line endings; this is not a fingerprinted fixture.
#pragma warning disable MA0136
    internal const string RowKernel = """
        extern "C" __global__ void mathblocks_row_probe(
            const int* opcodes, const double* a, const double* b, const double* c, double fill, double* values, int* valid, int count)
        {
            int row = blockIdx.x * blockDim.x + threadIdx.x;
            if (row >= count)
                return;
            double value = 0.0;
            valid[row] = mathblocks_elementwise_row(opcodes[row], a[row], b[row], c[row], fill, &value) ? 1 : 0;
            values[row] = value;
        }
        """;
#pragma warning restore MA0136

    /// <summary>Verifies the device source declares and defines the row function exactly as the public signature says, under the defaults and a configured domain.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void TheModuleSourceContainsTheElementwiseRowSignatureVerbatim()
    {
        var signature = MathBlockCudaDeviceModule.ElementwiseRowSignature;
        var configured = MathBlockCudaDeviceModule.GetSource(Configured());

        Assert.Contains(signature + ";", MathBlockCudaDeviceModule.Source, StringComparison.Ordinal);
        Assert.Contains(signature + "\n", MathBlockCudaDeviceModule.Source, StringComparison.Ordinal);
        Assert.Contains(signature + ";", configured, StringComparison.Ordinal);
        Assert.Contains(signature + "\n", configured, StringComparison.Ordinal);
        Assert.Equal(signature, MathBlockCudaDeviceModule.Abi.ElementwiseRowSignature, StringComparer.Ordinal);
    }

    /// <summary>Verifies a consumer-owned kernel that calls the row function compiles with NVRTC after the device source of the defaults and of a configured domain.</summary>
    [Theory]
    [Trait("Category", "NvrtcInteropContract")]
    [InlineData(false)]
    [InlineData(true)]
    public void AConsumerKernelThatCallsTheElementwiseRowFunctionCompilesWithNVRTC(bool configured)
    {
        var options = configured ? Configured() : MathBlockDomainOptions.Default;
        var composed = MathBlockCudaDeviceModule.ComposeSource(RowKernel, options);

        var bytes = (byte[])Compile.Invoke(null, [composed, "mathblocks-elementwise-row.cu", Architecture])!;

        Assert.Contains(".entry mathblocks_row_probe", Encoding.UTF8.GetString(bytes), StringComparison.Ordinal);
    }

    private static MathBlockDomainOptions Configured() => new()
    {
        IncompleteBetaMaximumIterations = 1024,
        IncompleteBetaTolerance = 1e-10f,
        MaximumMatrixSize = 5000,
        CubeRootNewtonSteps = 5
    };
}
