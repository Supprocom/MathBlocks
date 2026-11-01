using System.Reflection;
using System.Text.RegularExpressions;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies without a CUDA device that the operations whose CoreCLR side is a stable sort of their whole input are
/// ordered by the merge sort on CUDA, and that their scratch holds the other array of the merge.
/// </summary>
public sealed class MathBlockStableSortTests
{
    private static readonly MethodInfo ResolveScratchBytes = typeof(MathBlockCudaDeviceModule).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCUDAProgram", throwOnError: true)!
        .GetMethod(
            "ResolveScratchBytes",
            BindingFlags.Static | BindingFlags.NonPublic,
            [typeof(string), typeof(MathBlockType), typeof(MathBlockType[]), typeof(int[]), typeof(int[]), typeof(int[])])!;

    /// <summary>Gets the operations with their scratch in doubles for n rows: the data sorted, and the other array.</summary>
    public static TheoryData<string, int, long> ScratchDoubles => new()
    {
        { "statistics.pseudomedian@1", 1031, 1031L * 1032L },
        { "statistics.theil-sen-slope@1", 1031, 1031L * 1030L },
        { "statistics.interquartile-range@1", 1031, 2L * 1031L },
        { "vector.sort@1", 1031, 2L * 1031L },
        { "vector.median@1", 1031, 2L * 1031L },
        { "vector.quantile@1", 1031, 2L * 1031L },
        { "transport.uniform-wasserstein@1", 1031, 3L * 1031L },
        { "order.majorizes@1", 1031, 3L * 1031L },
        { "statistics.median-absolute-deviation@1", 1031, 2L * 1031L }
    };

    /// <summary>Verifies each scratch rule holds the merge sort's second array (the pair sets twice, the others once more).</summary>
    [Theory]
    [MemberData(nameof(ScratchDoubles))]
    public void CUDAScratchHoldsTheMergeSortBuffer(string identity, int rows, long expected)
    {
        var operation = MathBlockCatalog.Standard.Get(identity[..^2]);
        var inputs = operation.RegressionCases[0].Inputs.ToArray();
        var types = inputs.Select(input => input.Type.Kind == MathBlockValueKind.Vector ? MathBlockType.Vector(input.Type.Unit, rows) : input.Type).ToArray();
        var capacities = types.Select(type => type.Kind == MathBlockValueKind.Vector ? rows : 0).ToArray();
        var outputType = operation.ResolveOutputType(types);
        var bytes = (int)ResolveScratchBytes.Invoke(null, [identity, outputType, types, capacities, capacities, new int[types.Length]])!;
        Assert.Equal(expected * 8L, bytes);
    }

    /// <summary>Verifies the window scratch of the interquartile range holds the merge array and the pair forms keep theirs.</summary>
    [Fact]
    public void WindowScratchHoldsTheMergeSortBuffer()
    {
        var catalog = typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.WindowCudaBlockCatalog", throwOnError: true)!;
        var scratch = catalog.GetMethod("ScratchDoubles", BindingFlags.Static | BindingFlags.NonPublic)!;
        long Doubles(int source, long width) => (long)scratch.Invoke(null, [source, width])!;
        Assert.Equal(192L, Doubles(3, 96));
        Assert.Equal(96L * 97L, Doubles(15, 96));
        Assert.Equal(96L * 95L, Doubles(22, 96));
        Assert.Equal(96L, Doubles(47, 96));
    }

    /// <summary>
    /// Verifies the device functions that order a whole input call the stable merge sort and hold no insertion sort loop,
    /// by reading the generated source.
    /// </summary>
    [Theory]
    [InlineData("mathblocks_statistics_median")]
    [InlineData("mathblocks_statistics_sort_copy")]
    [InlineData("mathblocks_copy_and_sort")]
    [InlineData("mathblocks_quantile")]
    public void CUDASourceOrdersWholeInputsWithTheStableMergeSort(string function)
    {
        var body = FunctionBody(MathBlockCudaDeviceModule.Source, function);
        Assert.Contains("mathblocks_stable_", body, StringComparison.Ordinal);
        Assert.DoesNotContain("position--", body, StringComparison.Ordinal);
        Assert.DoesNotContain("position - 1", body, StringComparison.Ordinal);
    }

    private static string FunctionBody(string source, string function)
    {
        var match = Regex.Match(source, @"__device__ [^\n]*\b" + function + @"\([^)]*\)\s*(#line[^\n]*\n)?\s*\{", RegexOptions.None, TimeSpan.FromSeconds(10));
        while (match.Success && !source.AsSpan(match.Index).StartsWith("__device__", StringComparison.Ordinal))
            match = match.NextMatch();
        Assert.True(match.Success, $"{function} has no definition in the device source.");
        var depth = 0;
        for (var index = match.Index + match.Length - 1; index < source.Length; index++)
        {
            if (source[index] == '{')
                depth++;
            else if (source[index] == '}' && --depth == 0)
                return source[match.Index..(index + 1)];
        }

        throw new InvalidOperationException($"{function} has no closing brace.");
    }
}
