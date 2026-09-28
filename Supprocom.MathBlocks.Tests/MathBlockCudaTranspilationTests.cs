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
        "Transport"
    ];

    /// <summary>Verifies cudascalar unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAScalarUnitMatchesTheCSharp2CUDA031Golden()
    {
        AssertGeneratedUnit("Scalar", 0);
        Assert.Equal(CreateExpectedSource(), MathBlockCudaDeviceModule.Source);
        Assert.Equal(
            "6A6E8A49FD4DAD50A7B9007069A0D81A5957D7D6EE2C14FFB8DAE27BF18DCF84",
            MathBlockCudaDeviceModule.SourceFingerprint);
        Assert.Equal(
            "0179049D172FD0E7F7C514BB4AD3F6258054D3CD899B52E21AB5BDE05CD3A695",
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
