using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Cuda Transpilation Tests.</summary>
public sealed class MathBlockCudaTranspilationTests
{
    private static readonly string[] OperationCatalogs =
    [
        "Scalar",
        "Vector",
        "Complex",
        "Matrix",
        "Probability",
        "SequencePath",
        "Statistics",
        "Geometry",
        "Graph",
        "Advanced",
        "Transport",
        "Window",
        "Elementwise"
    ];

    /// <summary>Verifies cudascalar unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAScalarUnitMatchesTheCSharp2CUDA031Golden()
    {
        AssertGeneratedUnit("Scalar", 0);
        Assert.Equal(CreateExpectedSource(), MathBlockCudaDeviceModule.Source);
        Assert.Equal(
            "E6CC4D563B3C49C44EFB9FE00C8B92C1DFAC7FF86B65F7259A53FEA8826D8EEF",
            MathBlockCudaDeviceModule.SourceFingerprint);
        Assert.Equal(
            "0C482996948AD3D150B04D3ACD78D29CF874683F6D0BD2806BFAE3DA9485CE50",
            MathBlockCudaDeviceModule.Abi.OperationTableFingerprint);
    }

    /// <summary>Verifies cudavector unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAVectorUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Vector", 1);

    /// <summary>Verifies cudacomplex unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAComplexUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Complex", 2);

    /// <summary>Verifies cudamatrix unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAMatrixUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Matrix", 3);

    /// <summary>Verifies cudaprobability unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAProbabilityUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Probability", 4);

    /// <summary>Verifies cudasequence path unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDASequencePathUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("SequencePath", 5);

    /// <summary>Verifies cudastatistics unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAStatisticsUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Statistics", 6);

    /// <summary>Verifies cudageometry unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAGeometryUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Geometry", 7);

    /// <summary>Verifies cudagraph unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAGraphUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Graph", 8);

    /// <summary>Verifies cudaadvanced unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAAdvancedUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Advanced", 9);

    /// <summary>Verifies cudatransport unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDATransportUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Transport", 10);

    /// <summary>Verifies the CUDA window unit matches the CSharp2CUDA 0.3.1 golden.</summary>
    [Fact]
    public void CUDAWindowUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Window", 11);

    /// <summary>Verifies the CUDA elementwise unit matches the CSharp2CUDA 0.3.1 golden.</summary>
    [Fact]
    public void CUDAElementwiseUnitMatchesTheCSharp2CUDA031Golden() =>
        AssertGeneratedUnit("Elementwise", 12);

    /// <summary>Verifies cudadevice dispatch unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDADeviceDispatchUnitMatchesTheCSharp2CUDA031Golden()
    {
        var source = MathBlockCudaDeviceModule.Source;
        var start = OperationCatalogs.Sum(catalog => ReadGolden(catalog).Length + 1) + 1;
        var golden = ReadGolden("DeviceDispatch");

        Assert.Equal(golden, source[start..]);
    }

    private static void AssertGeneratedUnit(string catalog, int catalogIndex)
    {
        var source = MathBlockCudaDeviceModule.Source;
        var start = OperationCatalogs
            .Take(catalogIndex)
            .Sum(previous => ReadGolden(previous).Length + 1);
        var golden = ReadGolden(catalog);

        Assert.Equal(golden, source.Substring(start, golden.Length));
        Assert.Equal('\n', source[start + golden.Length]);
    }

    private static string CreateExpectedSource()
    {
        var builder = new StringBuilder();
        foreach (var catalog in OperationCatalogs)
            builder.Append(ReadGolden(catalog)).Append('\n');
        builder.Append('\n').Append(ReadGolden("DeviceDispatch"));
        return builder.ToString();
    }

    private static string ReadGolden(string catalog) =>
        File.ReadAllText(
                Path.Combine(AppContext.BaseDirectory, "Golden", $"{catalog}CudaBlockCatalog.cu"),
                Encoding.UTF8)
            .Replace("\r\n", "\n", StringComparison.Ordinal)
            .Replace('\r', '\n');
}
