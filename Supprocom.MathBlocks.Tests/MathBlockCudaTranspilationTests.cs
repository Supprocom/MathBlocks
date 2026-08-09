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

    [Fact]
    public void CUDA_vector_unit_matches_the_published_030_golden()
    {
        var golden = File.ReadAllText(
            Path.Combine(AppContext.BaseDirectory, "Golden", "VectorCudaBlockCatalog.cu"),
            Encoding.UTF8);
        var start = MathBlockCudaDeviceModule.Source.IndexOf(
            "__device__ double mathblocks_minimum",
            StringComparison.Ordinal);
        var end = MathBlockCudaDeviceModule.Source.IndexOf(
            "struct MathBlockComplexValue",
            StringComparison.Ordinal);

        Assert.True(start > 0);
        Assert.True(end > start);
        var actual = MathBlockCudaDeviceModule.Source[start..end];

        Assert.Equal(
            golden.Replace("\r\n", "\n", StringComparison.Ordinal),
            actual.Replace("\r\n", "\n", StringComparison.Ordinal));
    }

    [Fact]
    public void CUDA_complex_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "Complex",
            "struct MathBlockComplexValue",
            "__device__ void mathblocks_matrix");

    [Fact]
    public void CUDA_matrix_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "Matrix",
            "__device__ void mathblocks_matrix_shape",
            "__device__ bool mathblocks_probability_integer");

    [Fact]
    public void CUDA_probability_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "Probability",
            "__device__ bool mathblocks_probability_integer",
            "struct MathBlockSequencePathRun");

    [Fact]
    public void CUDA_sequence_path_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "SequencePath",
            "struct MathBlockSequencePathRun",
            "__device__ double mathblocks_statistics_mean");

    [Fact]
    public void CUDA_statistics_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "Statistics",
            "__device__ double mathblocks_statistics_mean",
            "struct MathBlockGeometryEdge");

    [Fact]
    public void CUDA_geometry_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "Geometry",
            "struct MathBlockGeometryEdge",
            "struct MathBlockGraphKernelEdge");

    [Fact]
    public void CUDA_graph_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "Graph",
            "struct MathBlockGraphKernelEdge",
            "__device__ bool mathblocks_advanced_power_of_two");

    [Fact]
    public void CUDA_advanced_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "Advanced",
            "__device__ bool mathblocks_advanced_power_of_two",
            "__device__ void mathblocks_transport_sort_values");

    [Fact]
    public void CUDA_transport_unit_matches_the_published_030_golden() =>
        AssertPublishedUnit(
            "Transport",
            "__device__ void mathblocks_transport_sort_values",
            "__device__ void mathblocks_operation_dispatch");

    [Fact]
    public void CUDA_device_dispatch_unit_matches_the_published_030_golden()
    {
        var golden = File.ReadAllText(
            Path.Combine(AppContext.BaseDirectory, "Golden", "DeviceDispatchCudaBlockCatalog.cu"),
            Encoding.UTF8);
        var source = MathBlockCudaDeviceModule.Source;
        var start = source.IndexOf(
            "__device__ void mathblocks_operation_dispatch",
            StringComparison.Ordinal);

        Assert.True(start > 0);
        var actual = source[start..];

        Assert.Equal(
            golden.Replace("\r\n", "\n", StringComparison.Ordinal),
            actual.Replace("\r\n", "\n", StringComparison.Ordinal));
    }

    private static void AssertPublishedUnit(
        string catalog,
        string startMarker,
        string endMarker)
    {
        var golden = File.ReadAllText(
            Path.Combine(AppContext.BaseDirectory, "Golden", $"{catalog}CudaBlockCatalog.cu"),
            Encoding.UTF8);
        var source = MathBlockCudaDeviceModule.Source;
        var start = source.IndexOf(startMarker, StringComparison.Ordinal);
        var end = source.IndexOf(endMarker, StringComparison.Ordinal);

        Assert.True(start > 0);
        Assert.True(end > start);
        var actual = source[start..end];

        var expected = golden.Replace("\r\n", "\n", StringComparison.Ordinal);
        if (catalog == "Transport")
            expected += "\n";

        Assert.Equal(expected, actual.Replace("\r\n", "\n", StringComparison.Ordinal));
    }
}
