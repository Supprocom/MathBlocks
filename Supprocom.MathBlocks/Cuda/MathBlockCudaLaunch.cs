using System.Text.Json;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Describes the geometry of one CUDA kernel launch.</summary>
/// <param name="Operation">The identity of the operation the launch runs, or the fused expression name.</param>
/// <param name="NodeIndex">The program node index, or null for a fused-expression launch.</param>
/// <param name="Blocks">The grid X after clamping.</param>
/// <param name="ThreadsPerBlock">The block size.</param>
/// <param name="ScratchBytesPerBlock">The scratch bytes of one block.</param>
/// <param name="WantedBlocks">The blocks the rows call for before any clamp.</param>
/// <param name="ClampedBy">The option property that reduced the grid, such as <c>MathBlocksCudaOptions.MaximumGridX</c>, or null.</param>
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
    public static void WriteJson(Utf8JsonWriter writer, IReadOnlyList<MathBlockCudaLaunch> launches)
        => throw new NotSupportedException("Not implemented yet.");
}
