using System.Reflection;
using System.Runtime.InteropServices;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the tests of the arena plan and the slot headers of the operations whose output is a square matrix of a runtime size, at the sizes the
/// domain options allow: they run the planning and the header writes of <c>MathBlocksCUDAProgram.Create</c> without a device.
/// </summary>
public sealed class MathBlockCudaLargeShapePlanTests
{
    private const int MaximumSquareSize = 16_383;

    private static readonly Type ProgramType = typeof(MathBlockCatalog).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCUDAProgram", throwOnError: true)!;

    /// <summary>Gets the operations and sizes: a size that is raised, one above the old header overflow, and the option's maximum.</summary>
    public static TheoryData<string, int> Sizes()
    {
        var data = new TheoryData<string, int>();
        foreach (var identity in new[] { "matrix.identity@1", "state.transition-counts@1" })
            foreach (var size in new[] { 4_097, 8_192, MaximumSquareSize })
                data.Add(identity, size);
        return data;
    }

    /// <summary>
    /// Verifies the plan of a program whose output is a square matrix of runtime size n x n holds its n * n payload in the arena, and the slot header
    /// of every node writes: the header count of a matrix whose shape is only known at run time is its capacity, not the product of two capacities.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaSourceContract")]
    [MemberData(nameof(Sizes))]
    public void TheArenaPlanAndTheSlotHeadersOfASquareMatrixOfRuntimeSizeFitInt(string identity, int size)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        MathBlockValue[] values = identity.StartsWith("matrix.", StringComparison.Ordinal)
            ? [MathBlockValue.Scalar(size)]
            : [MathBlockValue.Vector([0d, 1d, 2d, 1d]), MathBlockValue.Scalar(size)];
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = values.Select((value, index) => builder.Input($"input{index}", value.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(identity[..identity.LastIndexOf('@')], 1, nodes)).Build();
        var inputs = values.Select((value, index) => (Name: $"input{index}", Value: value)).ToDictionary(item => item.Name, item => item.Value, StringComparer.Ordinal);
        var domain = new MathBlockDomainOptions { MaximumStateCount = size, MaximumMatrixSize = size };

        var plan = ProgramType.GetMethod("PlanArenaFor", BindingFlags.Static | BindingFlags.NonPublic)!
            .Invoke(null, [program, inputs, MathBlocksCudaOptions.Default, domain, false])!;
        var arenaSize = (int)plan.GetType().GetProperty("ArenaSize")!.GetValue(plan)!;
        var slotOffsets = (int[])plan.GetType().GetProperty("SlotOffsets")!.GetValue(plan)!;
        var capacities = (int[])plan.GetType().GetProperty("Layout")!.GetValue(plan)!.GetType().GetProperty("Capacities")!.GetValue(plan.GetType().GetProperty("Layout")!.GetValue(plan))!;
        var types = (MathBlockType[])plan.GetType().GetProperty("Layout")!.GetValue(plan)!.GetType().GetProperty("ResolvedTypes")!.GetValue(plan.GetType().GetProperty("Layout")!.GetValue(plan))!;
        var output = program.OutputNodeIndexes["result"];

        Assert.Equal((long)size * size, capacities[output]);
        Assert.True(arenaSize >= checked(size * size * sizeof(double)), $"{identity} {size}: arena {arenaSize}");
        var buffer = Marshal.AllocHGlobal(slotOffsets.Max() + 4096);
        try
        {
            foreach (var node in program.PlanNodes)
                MathBlockCudaValueCodec.WriteHeader(buffer, slotOffsets[node.Index], 0ul, 0ul, capacities[node.Index], types[node.Index], valid: false);
        }
        finally
        {
            Marshal.FreeHGlobal(buffer);
        }
    }
}
