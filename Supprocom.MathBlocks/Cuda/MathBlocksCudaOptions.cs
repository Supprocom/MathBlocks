namespace Supprocom.MathBlocks.Cuda;

/// <summary>Sets the speed-only launch limits of CUDA programs; no value changes a result.</summary>
public sealed class MathBlocksCudaOptions
{
    /// <summary>Gets the option set with today's launch limits.</summary>
    public static MathBlocksCudaOptions Default { get; } = new();

    /// <summary>Gets the threads per block of every kernel launch except the fused-expression kernel and the scalar family.</summary>
    /// <remarks>Not a speed-only option until the per-kernel audit shows that no result depends on it.</remarks>
    public int BlockSize { get; init; } = 128;

    /// <summary>Gets the largest grid X of a row-striped launch (the CUDA device maximum is 2,147,483,647).</summary>
    public int MaximumGridX { get; init; } = 65_535;

    /// <summary>Gets the window scratch budget of one launch, in bytes.</summary>
    public long WindowScratchBudgetBytes { get; init; } = 256L * 1024 * 1024;

    /// <summary>Gets the largest number of blocks of a fused-expression launch.</summary>
    public int FusedMaximumBlocks { get; init; } = 4_096;

    /// <summary>Gets the block size of a fused-expression launch.</summary>
    public int FusedBlockSize { get; init; } = 256;
}
