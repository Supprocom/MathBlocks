using System.Globalization;
using System.Reflection;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the NVRTC and source tests of the per-row device functions <c>mathblocks_row_&lt;operation&gt;</c> and <c>mathblocks_row_sum</c>, which need NVRTC and no CUDA device:
/// the module source carries every signature the module publishes, a consumer-owned kernel that calls every function compiles after the device source of the defaults and of a
/// configured domain, a call with constant arguments compiles to PTX without a <c>call</c> instruction, and the generated source's default text is the library prelude's text.
/// </summary>
public sealed class MathBlockRowFunctionTests
{
    private const string Architecture = "compute_86";

    // The row functions in the order of the signature constants (mathblocks_row_sum comes after them): the function's operation, its number of double arguments and the
    // opcode of the scalar dispatch case it mirrors, which the device test runs through the dispatch.
    internal static readonly RowFunction[] Functions =
    [
        new("add", 2, 0), new("subtract", 2, 1), new("multiply", 2, 2), new("divide", 2, 3), new("absolute", 1, 5), new("square_root", 1, 14)
    ];

    private static readonly MethodInfo Compile = typeof(MathBlockCatalog).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
        .GetMethod(
            "CompilePtxWithoutDevice",
            BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public,
            [typeof(string), typeof(string), typeof(string)])!;

    // NVRTC ignores source line endings; these are not fingerprinted fixtures.
#pragma warning disable MA0136
    private const string InlineKernel = """
        extern "C" __global__ void mathblocks_row_inline(double* values, int* valid)
        {
            double value = 0.0;
            valid[0] = mathblocks_row_add(1.5, 2.25, -1.0, &value) ? 1 : 0;
            values[0] = value;
            valid[1] = mathblocks_row_divide(1.0, 4.0, -1.0, &value) ? 1 : 0;
            values[1] = value;
            valid[2] = mathblocks_row_absolute(-2.0, -1.0, &value) ? 1 : 0;
            values[2] = value;
            valid[3] = mathblocks_row_multiply(3.0, 0.5, -1.0, &value) ? 1 : 0;
            values[3] = value;
        }
        """;
#pragma warning restore MA0136

    /// <summary>Describes one row function: the operation, how many double arguments it takes, and the scalar dispatch opcode it mirrors.</summary>
    /// <param name="Operation">The operation name, as in <c>mathblocks_row_&lt;operation&gt;</c>.</param>
    /// <param name="Arity">The number of double arguments.</param>
    /// <param name="Opcode">The opcode of the scalar dispatch case the function mirrors.</param>
    internal sealed record RowFunction(string Operation, int Arity, int Opcode);

    /// <summary>Gets the source of a consumer kernel that calls every row function once with its arguments read from <c>x</c>.</summary>
    internal static string CallEveryFunctionKernel()
    {
        var text = new StringBuilder("extern \"C\" __global__ void mathblocks_row_probe(const double* x, const double* items, int count, double fill, double* y, int* v)\n{\n    double r = 0.0;\n");
        for (var index = 0; index < Functions.Length; index++)
        {
            var function = Functions[index];
            text.Append("    v[").Append(index.ToString(CultureInfo.InvariantCulture)).Append("] = mathblocks_row_").Append(function.Operation).Append('(');
            for (var argument = 0; argument < function.Arity; argument++)
                text.Append("x[").Append(argument.ToString(CultureInfo.InvariantCulture)).Append("], ");
            text.Append("fill, &r) ? 1 : 0;\n    y[").Append(index.ToString(CultureInfo.InvariantCulture)).Append("] = r;\n");
        }

        var sum = Functions.Length.ToString(CultureInfo.InvariantCulture);
        text.Append("    v[").Append(sum).Append("] = mathblocks_row_sum(items, count, fill, &r) ? 1 : 0;\n    y[").Append(sum).Append("] = r;\n}\n");
        return text.ToString();
    }

    /// <summary>Verifies the device source contains every published row function signature verbatim, under the defaults and a configured domain, and the ABI carries them.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void TheModuleSourceContainsEveryRowSignatureVerbatim()
    {
        var signatures = MathBlockCudaDeviceModule.RowFunctionSignatures.Split(';');
        var configured = MathBlockCudaDeviceModule.GetSource(Configured());

        Assert.Equal(Functions.Length + 1, signatures.Length);
        for (var index = 0; index < signatures.Length; index++)
        {
            Assert.Contains(signatures[index] + "\n", MathBlockCudaDeviceModule.Source, StringComparison.Ordinal);
            Assert.Contains(signatures[index] + "\n", configured, StringComparison.Ordinal);
        }

        for (var index = 0; index < Functions.Length; index++)
            Assert.StartsWith("static __device__ __forceinline__ bool mathblocks_row_" + Functions[index].Operation + "(", signatures[index], StringComparison.Ordinal);

        Assert.StartsWith("static __device__ __forceinline__ bool mathblocks_row_sum(", signatures[^1], StringComparison.Ordinal);
        Assert.Equal(MathBlockCudaDeviceModule.RowFunctionSignatures, MathBlockCudaDeviceModule.Abi.RowFunctionSignatures, StringComparer.Ordinal);
        Assert.NotEqual(
            MathBlockCudaDeviceModule.Abi.Fingerprint,
            (MathBlockCudaDeviceModule.Abi with { RowFunctionSignatures = string.Empty }).Fingerprint,
            StringComparer.Ordinal);
    }

    /// <summary>Verifies a consumer-owned kernel that calls every row function compiles with NVRTC after the device source of the defaults and of a configured domain.</summary>
    [Theory]
    [Trait("Category", "NvrtcInteropContract")]
    [InlineData(false)]
    [InlineData(true)]
    public void AConsumerKernelThatCallsEveryRowFunctionCompilesWithNVRTC(bool configured)
    {
        var options = configured ? Configured() : MathBlockDomainOptions.Default;
        var composed = MathBlockCudaDeviceModule.ComposeSource(CallEveryFunctionKernel(), options);

        var bytes = (byte[])Compile.Invoke(null, [composed, "mathblocks-row-functions.cu", Architecture])!;

        Assert.Contains(".entry mathblocks_row_probe", Encoding.UTF8.GetString(bytes), StringComparison.Ordinal);
    }

    /// <summary>Verifies the kernel of the device test, which runs each operation through the scalar dispatch and its row function, compiles with NVRTC.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void TheDispatchComparisonKernelCompilesWithNVRTC()
    {
        var composed = MathBlockCudaDeviceModule.ComposeSource(MathBlockRowFunctionDeviceTests.Kernel());

        var bytes = (byte[])Compile.Invoke(null, [composed, "mathblocks-row-dispatch.cu", Architecture])!;

        Assert.Contains(".entry row_vs_dispatch", Encoding.UTF8.GetString(bytes), StringComparison.Ordinal);
    }

    /// <summary>Verifies a kernel that calls add, divide, absolute and multiply with constants compiles to PTX with no call instruction: the functions are inlined.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void ARowFunctionCalledWithConstantsIsInlined()
    {
        var composed = MathBlockCudaDeviceModule.ComposeSource(InlineKernel);

        var ptx = Encoding.UTF8.GetString((byte[])Compile.Invoke(null, [composed, "mathblocks-row-inline.cu", Architecture])!);

        var start = ptx.IndexOf(".entry mathblocks_row_inline", StringComparison.Ordinal);
        Assert.True(start >= 0);
        var end = ptx.IndexOf("\n}", start, StringComparison.Ordinal);
        Assert.True(end > start);
        var body = ptx[start..end];
        Assert.DoesNotContain("call", body, StringComparison.Ordinal);
        Assert.DoesNotContain("mathblocks_row_", body[(".entry mathblocks_row_inline".Length)..], StringComparison.Ordinal);
    }

    /// <summary>Verifies the row functions of the generated source's default text are the library prelude's text, so a configured source and the generated source agree.</summary>
    [Fact]
    [Trait("Category", "CudaSourceContract")]
    public void TheGeneratedSourceDefaultsAndTheLibraryPreludeHaveTheSameRowFunctions()
    {
        var startMarker = "// Per-row arithmetic for a consumer's fused kernel";
        var endMarker = "return mathblocks_row_finish(true, sum, fill, result);\n}";
        var generated = (string)typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaGeneratedSource", throwOnError: true)!
            .GetField("Source")!.GetRawConstantValue()!;
        var defaults = MathBlockCudaDeviceModule.GetSource(MathBlockDomainOptions.Default);
        var guard = generated.IndexOf("#ifndef MATHBLOCKS_DOMAIN_PRELUDE", StringComparison.Ordinal);
        var guardEnd = generated.IndexOf("#endif", guard, StringComparison.Ordinal);

        var inGenerated = Extract(generated[guard..guardEnd], startMarker, endMarker);
        var inPrelude = Extract(defaults[..defaults.IndexOf("#ifndef MATHBLOCKS_DOMAIN_PRELUDE", StringComparison.Ordinal)], startMarker, endMarker);

        Assert.True(inGenerated.Length > 1000);
        Assert.Equal(inPrelude, inGenerated, StringComparer.Ordinal);
    }

    private static string Extract(string text, string start, string end)
    {
        var first = text.IndexOf(start, StringComparison.Ordinal);
        Assert.True(first >= 0);
        var last = text.IndexOf(end, first, StringComparison.Ordinal);
        Assert.True(last > first);
        return text[first..(last + end.Length)];
    }

    private static MathBlockDomainOptions Configured() => new()
    {
        IncompleteBetaMaximumIterations = 1024,
        IncompleteBetaTolerance = 1e-10,
        MaximumMatrixSize = 5000,
        CubeRootNewtonSteps = 5
    };
}
