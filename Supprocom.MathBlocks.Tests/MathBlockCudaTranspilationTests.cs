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

    /// <summary>
    /// Verifies the device source computes in single precision only. The transpiler's own conversion helpers take a double-precision
    /// parameter and its sign test converts its operand; those signatures and that conversion are the only places the type is named, and no
    /// double-precision rounding intrinsic is called.
    /// </summary>
    [Fact]
    public void CUDASourceNamesDoublePrecisionOnlyInTheTranspilerHelpers()
    {
        var source = MathBlockCudaDeviceModule.Source;
        foreach (var intrinsic in new[] { "__dadd_rn", "__dsub_rn", "__dmul_rn", "__ddiv_rn", "__dsqrt_rn" })
            Assert.DoesNotContain(intrinsic, source, StringComparison.Ordinal);
        string[] helperParameterLines = ["double value)", "double value,", "double minimum,", "double maximum)"];
        foreach (var line in source.Split('\n'))
        {
            if (!NamesDoubleType(line))
                continue;
            var text = line.Trim();
            var allowed = text.Contains("csharp2cuda_f64_", StringComparison.Ordinal) ||
                          text.Contains("signbit(((double)(", StringComparison.Ordinal) ||
                          Array.IndexOf(helperParameterLines, text) >= 0;
            Assert.True(allowed, "The device source names double precision in: " + text);
        }
    }

    // True when the line holds the word double as a type name, not as part of a longer identifier.
    private static bool NamesDoubleType(string line)
    {
        const string word = "double";
        for (var index = line.IndexOf(word, StringComparison.Ordinal);
             index >= 0;
             index = line.IndexOf(word, index + 1, StringComparison.Ordinal))
        {
            var end = index + word.Length;
            var startsWord = index == 0 || !(char.IsLetterOrDigit(line[index - 1]) || line[index - 1] == '_');
            var endsWord = end == line.Length || !(char.IsLetterOrDigit(line[end]) || line[end] == '_');
            if (startsWord && endsWord)
                return true;
        }

        return false;
    }

    /// <summary>Verifies cudascalar unit matches the csharp 2 cuda 031 golden.</summary>
    [Fact]
    public void CUDAScalarUnitMatchesTheCSharp2CUDA031Golden()
    {
        AssertGeneratedUnit("Scalar", 0);
        // The device source is the domain-limit prelude followed by the generated units.
        Assert.EndsWith(CreateExpectedSource(), MathBlockCudaDeviceModule.Source, StringComparison.Ordinal);
        Assert.Equal(MathBlockCudaDeviceModule.GetSource(MathBlockDomainOptions.Default), MathBlockCudaDeviceModule.Source);
        Assert.True(
            string.Equals(
                "3EC1D97B919142F05EA54383B07E905548DA118B6D4F82588466E16786B9F41E",
                MathBlockCudaDeviceModule.SourceFingerprint,
                StringComparison.Ordinal),
            "The source fingerprint is " + MathBlockCudaDeviceModule.SourceFingerprint);
        Assert.True(
            string.Equals(
                "AF0012FF7AA863D2E7C2544E8947201583BF231C752ABCDCCC9B9FB11D22349D",
                MathBlockCudaDeviceModule.Abi.OperationTableFingerprint,
                StringComparison.Ordinal),
            "The operation table fingerprint is " + MathBlockCudaDeviceModule.Abi.OperationTableFingerprint);
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
        var source = GeneratedUnits();
        var start = OperationCatalogs.Sum(catalog => ReadGolden(catalog).Length + 1) + 1;
        var golden = ReadGolden("DeviceDispatch");

        Assert.Equal(golden, source[start..]);
    }

    // The device source after its domain-limit prelude: the generated units.
    private static string GeneratedUnits() =>
        MathBlockCudaDeviceModule.Source[^CreateExpectedSource().Length..];

    private static void AssertGeneratedUnit(string catalog, int catalogIndex)
    {
        var source = GeneratedUnits();
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
