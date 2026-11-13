namespace Supprocom.MathBlocks.Cuda;

/// <summary>Sets the launch limits of CUDA programs; no value changes a result.</summary>
/// <remarks>
/// Every property changes only how rows and scratch are spread over the CUDA device. CoreCLR and CUDA results are bit for bit the same
/// at every allowed value: a cooperative kernel whose work depends on the block size runs a fixed partition of
/// <see cref="MathBlockCudaDeviceModule.VirtualLaneCount"/> virtual lanes, and every other kernel gives each output to one lane or one
/// row to one thread. <see cref="MathBlocksCUDAWorker.CompileWithOptions"/> checks each value against the device and the program.
/// </remarks>
public sealed class MathBlocksCudaOptions
{
    /// <summary>Gets the option set with today's launch limits.</summary>
    public static MathBlocksCudaOptions Default { get; } = new();

    /// <summary>Gets the threads per block of every kernel launch except the fused-expression kernel and the scalar family.</summary>
    /// <remarks>From 1 up to the CUDA device maximum threads per block and the maximum of each compiled kernel the program launches. A larger block adds threads without changing a result; a block above 128 leaves its extra threads idle in the phases that use 128 virtual lanes. The window scratch of one block grows with it, so the largest window width of the scratch-limited forms shrinks.</remarks>
    public int BlockSize { get; init; } = 128;

    /// <summary>Gets the largest grid X of a row-striped launch.</summary>
    /// <remarks>From 1 up to the CUDA device maximum grid X (2,147,483,647 on current devices). Rows beyond the clamped grid stripe over the blocks: thread t of a launch takes the rows t, t + threads, ..., so every row is still computed, by the same expression.</remarks>
    public int MaximumGridX { get; init; } = 65_535;

    /// <summary>Gets the window scratch budget of one launch, in bytes.</summary>
    /// <remarks>At least the scratch of one block of each window form in the program, and at most <see cref="int.MaxValue"/> because the scratch is addressed with int byte offsets. The grid of a window launch is cut to the blocks whose scratch fits; the rows stripe over the remaining blocks.</remarks>
    public long WindowScratchBudgetBytes { get; init; } = 256L * 1024 * 1024;

    /// <summary>Gets the largest number of blocks of a fused-expression launch.</summary>
    /// <remarks>From 1 up to the CUDA device maximum grid X. Rows beyond the clamped grid stripe over the blocks.</remarks>
    public int FusedMaximumBlocks { get; init; } = 4_096;

    /// <summary>Gets the number of rows one CoreCLR task evaluates in a fused expression.</summary>
    /// <remarks>At least 1. Every row is independent and the invalid masks combine by bitwise or, so the value changes only the speed of <see cref="MathBlockFusedExpression.EvaluateCoreCLR(System.Collections.Generic.IReadOnlyDictionary{string, MathBlockValue}, System.Collections.Generic.IReadOnlyDictionary{string, MathBlockValue}?, MathBlockDomainOptions, MathBlocksCudaOptions)"/>.</remarks>
    public int FusedRowBlock { get; init; } = 8192;

    /// <summary>Gets the ordinal of the CUDA device the program runs on.</summary>
    /// <remarks>From 0 up to one less than the number of CUDA devices (<c>cuDeviceGetCount</c>); an ordinal outside that range is an <see cref="ArgumentOutOfRangeException"/> that names the count. The device's architecture, its limits and its primary context are those of this ordinal, and every call of the program runs in that context.</remarks>
    public int DeviceOrdinal { get; init; }

    /// <summary>Gets the block size of a fused-expression launch.</summary>
    /// <remarks>From 1 up to the CUDA device maximum threads per block.</remarks>
    public int FusedBlockSize { get; init; } = 256;
}
