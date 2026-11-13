using System.Text.Json;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Describes the geometry of one CUDA kernel launch.</summary>
/// <param name="Operation">The identity of the operation the launch runs, or the fused expression name.</param>
/// <param name="NodeIndex">The program node index, or null for a fused-expression launch.</param>
/// <param name="Blocks">The grid X after clamping.</param>
/// <param name="ThreadsPerBlock">The block size.</param>
/// <param name="ScratchBytesPerBlock">The scratch bytes of one block.</param>
/// <param name="WantedBlocks">The blocks the rows call for before any clamp.</param>
/// <param name="ClampedBy">The name of the option that reduced the grid (<c>MaximumGridX</c>, <c>WindowScratchBudgetBytes</c> or <c>FusedMaximumBlocks</c>), or null when no clamp applied.</param>
/// <remarks>
/// A clamp is speed-only: results are bit for bit unchanged. When <see cref="Blocks"/> is below <see cref="WantedBlocks"/>, the rows
/// stripe over the blocks that remain: thread t of the launch (block index times <see cref="ThreadsPerBlock"/> plus thread index) takes the rows
/// t, t + threads, t + 2 * threads, ... with threads = <see cref="Blocks"/> times <see cref="ThreadsPerBlock"/>. The window forms that slide state
/// over a block of rows give each thread a block of consecutive rows instead and replay the rows before it, with the same result.
/// </remarks>
public sealed record MathBlockCudaLaunch(
    string Operation,
    int? NodeIndex,
    int Blocks,
    int ThreadsPerBlock,
    long ScratchBytesPerBlock,
    long WantedBlocks,
    string? ClampedBy)
{
    /// <summary>Writes the launches as a JSON array with stable field names and order.</summary>
    /// <remarks>One object per launch with the fields <c>operation</c>, <c>nodeIndex</c>, <c>blocks</c>, <c>threadsPerBlock</c>, <c>scratchBytesPerBlock</c>, <c>wantedBlocks</c> and <c>clampedBy</c>, in that order; <c>nodeIndex</c> and <c>clampedBy</c> are null when absent.</remarks>
    public static void WriteJson(Utf8JsonWriter writer, IReadOnlyList<MathBlockCudaLaunch> launches)
    {
        ArgumentNullException.ThrowIfNull(writer);
        ArgumentNullException.ThrowIfNull(launches);
        writer.WriteStartArray();
        foreach (var launch in launches)
        {
            writer.WriteStartObject();
            writer.WriteString("operation", launch.Operation);
            if (launch.NodeIndex is { } nodeIndex)
                writer.WriteNumber("nodeIndex", nodeIndex);
            else
                writer.WriteNull("nodeIndex");
            writer.WriteNumber("blocks", launch.Blocks);
            writer.WriteNumber("threadsPerBlock", launch.ThreadsPerBlock);
            writer.WriteNumber("scratchBytesPerBlock", launch.ScratchBytesPerBlock);
            writer.WriteNumber("wantedBlocks", launch.WantedBlocks);
            if (launch.ClampedBy is { } clampedBy)
                writer.WriteString("clampedBy", clampedBy);
            else
                writer.WriteNull("clampedBy");
            writer.WriteEndObject();
        }
        writer.WriteEndArray();
    }
}
