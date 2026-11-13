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
    // The element before the insertion position, which every insertion sort of the first CUDA source reads (the translated
    // form of sorted[position - 1]).
    private const string InsertionShift = "csharp2cuda_i32_sub(position, 1)]";

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
        { "statistics.median-absolute-deviation@1", 1031, 2L * 1031L },
        { "inequality.lorenz-curve@1", 1031, 1031L },
        { "transport.weighted-wasserstein-1@1", 1031, 2L * 1031L },
        { "geometry.convex-hull@1", 1031, 8L * 1031L },
        { "topology.zero-dimensional-persistence@1", 1031, 2L * 1031L * 1030L + 2L * 1031L }
    };

    /// <summary>Verifies each scratch rule holds the merge sort's second array (the pair sets twice, the others once more).</summary>
    [Theory]
    [MemberData(nameof(ScratchDoubles))]
    public void CUDAScratchHoldsTheMergeSortBuffer(string identity, int rows, long expected)
    {
        var operation = MathBlockCatalog.Standard.Get(identity[..^2]);
        var inputs = operation.RegressionCases[0].Inputs.ToArray();
        var types = inputs.Select(input => input.Type.Kind switch
        {
            MathBlockValueKind.Vector => MathBlockType.Vector(input.Type.Unit, rows),
            MathBlockValueKind.PointSet => MathBlockType.PointSet(input.Type.Unit, rows),
            _ => input.Type
        }).ToArray();
        var capacities = types.Select(type => type.Kind is MathBlockValueKind.Vector or MathBlockValueKind.PointSet ? rows : 0).ToArray();
        var outputType = operation.ResolveOutputType(types);
        var bytes = (int)ResolveScratchBytes.Invoke(null, [identity, outputType, types, capacities, capacities, new int[types.Length]])!;
        Assert.Equal(expected * 8L, bytes);
    }

    /// <summary>
    /// Verifies the plan rejects a pair form above the row count its scratch byte count allows with a message that names the
    /// operation and the limit, and plans the largest allowed count: 16,383 rows for the pseudomedian, 16,384 for Theil-Sen.
    /// </summary>
    [Theory]
    [InlineData("statistics.pseudomedian", 16_383)]
    [InlineData("statistics.theil-sen-slope", 16_384)]
    [InlineData("vector.sort", 134_217_727)]
    [InlineData("transport.uniform-wasserstein", 89_478_485)]
    public void CUDAPlanRejectsRowCountsAboveTheScratchLimitWithAClearMessage(string identifier, int limit)
    {
        var identity = $"{identifier}@1";
        var operation = MathBlockCatalog.Standard.Get(identifier);
        var sample = operation.RegressionCases[0].Inputs;
        MathBlockProgram Build(int rows)
        {
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var nodes = sample.Select((input, index) => builder.Input($"input-{index}", input.Type.Kind == MathBlockValueKind.Vector ? MathBlockType.Vector(input.Type.Unit, rows) : input.Type)).ToArray();
            return builder.Output("result", builder.Apply(identifier, 1, nodes)).Build();
        }

        int Plan(int rows)
        {
            var program = Build(rows);
            // The prototype shapes only: a vector of the planned length is enough, the values are not read by the plan.
            var layout = typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCUDAProgram", throwOnError: true)!
                .GetMethods(BindingFlags.Static | BindingFlags.NonPublic)
                .Single(method => string.Equals(method.Name, "ResolvePayloadLayout", StringComparison.Ordinal))
                .Invoke(null, [program.PlanNodes, null, null, null, null, null])!;
            var scratch = typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCUDAProgram", throwOnError: true)!
                .GetMethods(BindingFlags.Static | BindingFlags.NonPublic)
                .Single(method => string.Equals(method.Name, "ResolveScratchBytes", StringComparison.Ordinal) && method.GetParameters().Length == 3);
            var node = program.PlanNodes.Single(item => item.Kind == MathBlockProgramNodeKind.Operation);
            try
            {
                return (int)scratch.Invoke(null, [node, program.PlanNodes, layout])!;
            }
            catch (TargetInvocationException exception) when (exception.InnerException is not null)
            {
                throw exception.InnerException;
            }
        }

        Assert.True(Plan(limit) > 0);
        var rejected = Assert.Throws<InvalidOperationException>(() => Plan(limit + 1));
        Assert.Equal(
            string.Create(System.Globalization.CultureInfo.InvariantCulture, $"{identity}: CUDA supports at most {limit:N0} rows (scratch byte count); got {limit + 1:N0}."),
            rejected.Message);
    }

    /// <summary>Verifies the window plan rejects a width above the limit of its scratch with a message that names the operation and the limit.</summary>
    [Fact]
    public void CUDAWindowPlanRejectsWidthsAboveTheScratchLimitWithAClearMessage()
    {
        var program = typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCUDAProgram", throwOnError: true)!;
        var operation = MathBlockWindowTestSupport.Windowed.Get("window.statistics.pseudomedian");
        var sample = operation.RegressionCases[0].Inputs.ToArray();
        MathBlockProgram Build(int width)
        {
            var builder = new MathBlockProgramBuilder(MathBlockWindowTestSupport.Windowed);
            var nodes = sample.Select((input, index) => index == 1
                ? builder.Constant(MathBlockValue.Scalar(width, input.Type.Unit))
                : builder.Input($"input-{index}", input.Type.Kind == MathBlockValueKind.Vector ? MathBlockType.Vector(input.Type.Unit, 3_000) : input.Type)).ToArray();
            return builder.Output("result", builder.Apply("window.statistics.pseudomedian", 1, nodes)).Build();
        }

        void Plan(int width)
        {
            var built = Build(width);
            var layout = program.GetMethods(BindingFlags.Static | BindingFlags.NonPublic).Single(method => string.Equals(method.Name, "ResolvePayloadLayout", StringComparison.Ordinal)).Invoke(null, [built.PlanNodes, null, null, null, null, null])!;
            var scratch = program.GetMethods(BindingFlags.Static | BindingFlags.NonPublic).Single(method => string.Equals(method.Name, "ResolveScratchBytes", StringComparison.Ordinal) && method.GetParameters().Length == 3);
            try
            {
                scratch.Invoke(null, [built.PlanNodes.Single(item => item.Kind == MathBlockProgramNodeKind.Operation), built.PlanNodes, layout]);
            }
            catch (TargetInvocationException exception) when (exception.InnerException is not null)
            {
                throw exception.InnerException;
            }
        }

        Plan(1_447);
        var rejected = Assert.Throws<InvalidOperationException>(() => Plan(1_448));
        Assert.Equal(
            "window.statistics.pseudomedian@1: CUDA supports widths of at most 1,447 for this operation (scratch byte count); got 1,448.",
            rejected.Message);
    }

    /// <summary>
    /// Verifies the device source holds an insertion loop only in the functions whose sorted array is a window, a value list of at
    /// most 30 entries, or the window's quantile fallback: every sort of a whole input is the merge sort.
    /// </summary>
    [Fact]
    public void CUDASourceKeepsInsertionLoopsOnlyInTheBoundedFunctions()
    {
        var source = MathBlockCudaDeviceModule.Source;
        var owners = new SortedSet<string>(StringComparer.Ordinal);
        var index = source.IndexOf(InsertionShift, StringComparison.Ordinal);
        while (index >= 0)
        {
            var start = source.LastIndexOf("\n__device__ ", index, StringComparison.Ordinal);
            var open = source.IndexOf('(', start);
            var name = source[source.LastIndexOf(' ', open)..open].Trim();
            owners.Add(name);
            index = source.IndexOf(InsertionShift, index + 1, StringComparison.Ordinal);
        }

        Assert.Equal(["mathblocks_advanced_dispatch", "mathblocks_sort_copy_values", "mathblocks_window_sorted_rows"], owners);
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
    [InlineData("mathblocks_matrix_symmetric_eigenvalues")]
    public void CUDASourceOrdersWholeInputsWithTheStableMergeSort(string function)
    {
        var body = FunctionBody(MathBlockCudaDeviceModule.Source, function);
        Assert.Contains("mathblocks_stable_", body, StringComparison.Ordinal);
        Assert.DoesNotContain(InsertionShift, body, StringComparison.Ordinal);
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
