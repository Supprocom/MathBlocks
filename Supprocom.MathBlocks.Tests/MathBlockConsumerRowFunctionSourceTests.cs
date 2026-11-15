using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the tests of <see cref="MathBlockCudaDeviceModule.ConsumerRowFunctionSource"/>, the per-row function text a consumer prepends to its own
/// translation unit when it compiles that unit apart from the module and links the two: the text is the module's own, defines no device variable,
/// compiles alone as relocatable device code with every row function inlined, and the module's relocatable unit exports the square root it declares.
/// </summary>
public sealed class MathBlockConsumerRowFunctionSourceTests
{
    private const string Architecture = "compute_86";

    private static readonly MethodInfo Compile = typeof(MathBlockCatalog).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
        .GetMethod(
            "CompilePtxWithoutDevice",
            BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public,
            [typeof(string), typeof(string), typeof(string), typeof(bool), typeof(bool)])!;

    // A consumer kernel that calls every row function. Its name does not start with mathblocks_row_, so any mathblocks_row_ name left in the PTX
    // is a row function that was not inlined. NVRTC ignores source line endings; this is not a fingerprinted fixture.
#pragma warning disable MA0136
    private const string ConsumerKernel = """
        extern "C" __global__ void consumer_rows_probe(const double* a, const double* b, double fill, double* values, int* valid, int count)
        {
            int row = blockIdx.x * blockDim.x + threadIdx.x;
            if (row >= count)
                return;
            double value = 0.0;
            int flags = 0;
            flags |= mathblocks_row_add(a[row], b[row], fill, &value) ? 1 : 0;
            values[row * 7] = value;
            flags |= mathblocks_row_subtract(a[row], b[row], fill, &value) ? 2 : 0;
            values[row * 7 + 1] = value;
            flags |= mathblocks_row_multiply(a[row], b[row], fill, &value) ? 4 : 0;
            values[row * 7 + 2] = value;
            flags |= mathblocks_row_divide(a[row], b[row], fill, &value) ? 8 : 0;
            values[row * 7 + 3] = value;
            flags |= mathblocks_row_absolute(a[row], fill, &value) ? 16 : 0;
            values[row * 7 + 4] = value;
            flags |= mathblocks_row_square_root(a[row], fill, &value) ? 32 : 0;
            values[row * 7 + 5] = value;
            flags |= mathblocks_row_sum(a, count, fill, &value) ? 64 : 0;
            values[row * 7 + 6] = value;
            valid[row] = flags;
        }
        """;
#pragma warning restore MA0136

    /// <summary>
    /// Verifies the consumer text is the module source's own row-function text, defines every published row function, declares and defines no
    /// device variable, and matches its published fingerprint.
    /// </summary>
    [Fact]
    public void TheConsumerSourceIsTheModuleTextAndDefinesNoDeviceVariable()
    {
        var text = MathBlockCudaDeviceModule.ConsumerRowFunctionSource;

        Assert.Contains(text, MathBlockCudaDeviceModule.Source, StringComparison.Ordinal);
        var signatures = MathBlockCudaDeviceModule.RowFunctionSignatures.Split(';');
        for (var index = 0; index < signatures.Length; index++)
            Assert.Contains(signatures[index] + "\n", text, StringComparison.Ordinal);

        var lines = text.Split('\n');
        for (var index = 0; index < lines.Length; index++)
        {
            if (lines[index].StartsWith("__device__", StringComparison.Ordinal))
                Assert.EndsWith(");", lines[index], StringComparison.Ordinal);
        }

        Assert.DoesNotContain("__constant__", text, StringComparison.Ordinal);
        Assert.DoesNotContain("__shared__", text, StringComparison.Ordinal);
        Assert.DoesNotContain(MathBlockCudaDeviceModule.NonConvergenceCountsSymbol, text, StringComparison.Ordinal);
        Assert.DoesNotContain(MathBlockCudaDeviceModule.BinomialTableSymbol, text, StringComparison.Ordinal);
        Assert.Equal(
            Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(text))),
            MathBlockCudaDeviceModule.ConsumerRowFunctionSourceFingerprint,
            StringComparer.Ordinal);
    }

    /// <summary>
    /// Verifies a consumer unit made of the consumer text and a kernel that calls every row function compiles alone with NVRTC as relocatable device
    /// code, with every row function inlined, no device variable, and the square root left as an external function for the link to resolve.
    /// </summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void AConsumerUnitWithTheRowSourceCompilesAloneAsRelocatableCodeWithTheRowsInlined()
    {
        var source = MathBlockCudaDeviceModule.ConsumerRowFunctionSource + "\n" + ConsumerKernel;

        var ptx = CompileToPtx(source, "mathblocks-consumer-rows.cu");

        Assert.DoesNotContain("mathblocks_row_", ptx, StringComparison.Ordinal);
        Assert.Contains("consumer_rows_probe", ptx, StringComparison.Ordinal);
        var lines = ptx.Split('\n');
        var externalSquareRoot = false;
        for (var index = 0; index < lines.Length; index++)
        {
            var line = lines[index];
            var directive = line.TrimStart();
            // A device variable is a .global state-space directive; ld.global and st.global instructions are accesses, not definitions.
            Assert.False(
                directive.StartsWith(".global", StringComparison.Ordinal) ||
                directive.StartsWith(".visible .global", StringComparison.Ordinal) ||
                directive.StartsWith(".extern .global", StringComparison.Ordinal) ||
                directive.StartsWith(".weak .global", StringComparison.Ordinal),
                $"The consumer unit declares a device variable: {line}");
            if (line.Contains(".extern", StringComparison.Ordinal) &&
                line.Contains(".func", StringComparison.Ordinal) &&
                line.Contains("mathblocks_square_root", StringComparison.Ordinal))
                externalSquareRoot = true;
        }

        Assert.True(externalSquareRoot, "The consumer unit does not declare mathblocks_square_root as an external function.");
    }

    /// <summary>
    /// Verifies the module source compiled as relocatable device code exports <c>mathblocks_square_root</c> as a visible function, which is the
    /// definition a relocatable consumer unit's declaration links to.
    /// </summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void TheModuleUnitCompiledAsRelocatableCodeExportsTheSquareRoot()
    {
        var ptx = CompileToPtx(MathBlockCudaDeviceModule.Source, "mathblocks-module.cu");

        var lines = ptx.Split('\n');
        var visibleSquareRoot = false;
        for (var index = 0; index < lines.Length; index++)
        {
            var line = lines[index];
            if (line.Contains(".visible", StringComparison.Ordinal) &&
                line.Contains(".func", StringComparison.Ordinal) &&
                line.Contains("mathblocks_square_root", StringComparison.Ordinal))
                visibleSquareRoot = true;
        }

        Assert.True(visibleSquareRoot, "The module unit does not export mathblocks_square_root as a visible function.");
    }

    private static string CompileToPtx(string source, string name)
    {
        try
        {
            var bytes = (byte[])Compile.Invoke(null, [source, name, Architecture, false, true])!;
            return Encoding.UTF8.GetString(bytes).TrimEnd('\0');
        }
        catch (TargetInvocationException exception) when (exception.InnerException is not null)
        {
            throw new InvalidOperationException($"{name}: {exception.InnerException.Message}", exception.InnerException);
        }
    }
}
