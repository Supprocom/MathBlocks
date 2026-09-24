using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

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

    [Fact]
    public void CUDA_scalar_unit_matches_the_CSharp2CUDA_0_3_1_golden()
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

    [Fact]
    public void CUDA_vector_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Vector", 1);

    [Fact]
    public void CUDA_complex_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Complex", 2);

    [Fact]
    public void CUDA_matrix_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Matrix", 3);

    [Fact]
    public void CUDA_probability_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Probability", 4);

    [Fact]
    public void CUDA_sequence_path_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("SequencePath", 5);

    [Fact]
    public void CUDA_statistics_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Statistics", 6);

    [Fact]
    public void CUDA_geometry_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Geometry", 7);

    [Fact]
    public void CUDA_graph_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Graph", 8);

    [Fact]
    public void CUDA_advanced_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Advanced", 9);

    [Fact]
    public void CUDA_transport_unit_matches_the_CSharp2CUDA_0_3_1_golden() =>
        AssertGeneratedUnit("Transport", 10);

    [Fact]
    public void CUDA_device_dispatch_unit_matches_the_CSharp2CUDA_0_3_1_golden()
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
