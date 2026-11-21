using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains the NVRTC tests of the binomial table, which need NVRTC and no CUDA device: a consumer kernel compiles after the device source and the table symbol has its size.</summary>
public sealed partial class MathBlockBinomialTableNvrtcTests
{
    private const string Architecture = "compute_86";

    private static readonly MethodInfo Compile = typeof(MathBlockCatalog).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
        .GetMethod(
            "CompilePtxWithoutDevice",
            BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public,
            [typeof(string), typeof(string), typeof(string), typeof(bool)])!;

    // A consumer kernel that reads and writes the table through its public name, and evaluates a pair through the memo function.
    private const string Consumer =
        "extern \"C\" __global__ void consumer_binomial(double* output, int n, int k)\n" +
        "{\n" +
        "    double value = mathblocks_probability_binomial_memo(n, k);\n" +
        "    mathblocks_binomial_table_store(0, value);\n" +
        "    output[0] = value + mathblocks_binomial_table_load(1) + " + MathBlockCudaDeviceModule.BinomialTableSymbol + "[2];\n" +
        "}\n";

    [GeneratedRegex(
        @"\b" + MathBlockCudaDeviceModule.BinomialTableSymbol + @"\[(?<size>\d+)\]",
        RegexOptions.CultureInvariant | RegexOptions.ExplicitCapture,
        matchTimeoutMilliseconds: 10_000)]
    private static partial Regex TableDeclaration();

    private static string CompileConsumer(MathBlockDomainOptions options)
    {
        var composed = MathBlockCudaDeviceModule.ComposeSource(Consumer, options);
        try
        {
            var bytes = (byte[])Compile.Invoke(null, [composed, "mathblocks-binomial-consumer.cu", Architecture, false])!;
            return Encoding.UTF8.GetString(bytes);
        }
        catch (TargetInvocationException exception) when (exception.InnerException is not null)
        {
            throw new InvalidOperationException(exception.InnerException.Message, exception.InnerException);
        }
    }

    /// <summary>Verifies a consumer kernel that names the table and the memo function compiles with NVRTC after the device source of the defaults and of configured options.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void AConsumerKernelThatUsesTheTableCompilesWithNVRTC()
    {
        var defaults = CompileConsumer(MathBlockDomainOptions.Default);
        var configured = CompileConsumer(new MathBlockDomainOptions { MaximumStateCount = 8192, IncompleteBetaMaximumIterations = 1024 });

        Assert.Contains(".entry consumer_binomial", defaults, StringComparison.Ordinal);
        Assert.Contains(".entry consumer_binomial", configured, StringComparison.Ordinal);
        Assert.Contains(MathBlockCudaDeviceModule.BinomialTableSymbol, defaults, StringComparison.Ordinal);
    }

    /// <summary>Verifies the table symbol in the PTX has the size of 262,656 doubles, declared as 2,101,248 bytes or as 262,656 elements, once.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void TheTableSymbolHasTheSizeOfTheTable()
    {
        var ptx = CompileConsumer(MathBlockDomainOptions.Default);
        var declarations = TableDeclaration().Matches(ptx);

        Assert.Single(declarations);
        var size = int.Parse(declarations[0].Groups["size"].Value, System.Globalization.CultureInfo.InvariantCulture);
        Assert.True(
            size == MathBlockCudaDeviceModule.BinomialTableEntryCount * sizeof(float) || size == MathBlockCudaDeviceModule.BinomialTableEntryCount,
            $"The table is declared with {size} elements.");
    }
}
