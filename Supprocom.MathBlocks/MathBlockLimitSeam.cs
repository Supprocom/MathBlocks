using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks;

// The limit catalog reads CUDA option values that are not yet properties of MathBlocksCudaOptions through this
// seam: the device ordinal and the fused row block. Each member returns today's default until the CUDA options
// declare the property, and then reads it.
internal static class MathBlockLimitSeam
{
    internal const int DefaultDeviceOrdinal = 0;
    internal const int DefaultFusedRowBlock = 8192;

    // The largest threads-per-block value of every CUDA architecture the library targets.
    internal const int MaximumThreadsPerBlock = 1024;

    internal static int DeviceOrdinal(MathBlocksCudaOptions options)
    {
        ArgumentNullException.ThrowIfNull(options);
        return DefaultDeviceOrdinal;
    }

    internal static int FusedRowBlock(MathBlocksCudaOptions options)
    {
        ArgumentNullException.ThrowIfNull(options);
        return DefaultFusedRowBlock;
    }

    // Rejects a CUDA option that no launch can honor, naming the real limit.
    internal static void ValidateCuda(MathBlocksCudaOptions options)
    {
        RequireRange(options.BlockSize, 1, MaximumThreadsPerBlock, nameof(MathBlocksCudaOptions.BlockSize), "the CUDA limit is 1,024 threads per block");
        RequireRange(options.MaximumGridX, 1, int.MaxValue, nameof(MathBlocksCudaOptions.MaximumGridX), "the CUDA limit of grid X is 2,147,483,647 blocks");
        RequireRange(options.WindowScratchBudgetBytes, 1, long.MaxValue, nameof(MathBlocksCudaOptions.WindowScratchBudgetBytes), "the budget is a positive 64-bit byte count");
        RequireRange(options.FusedMaximumBlocks, 1, int.MaxValue, nameof(MathBlocksCudaOptions.FusedMaximumBlocks), "the CUDA limit of grid X is 2,147,483,647 blocks");
        RequireRange(options.FusedBlockSize, 1, MaximumThreadsPerBlock, nameof(MathBlocksCudaOptions.FusedBlockSize), "the CUDA limit is 1,024 threads per block");
    }

    private static void RequireRange(long value, long minimum, long maximum, string name, string reason)
    {
        if (value < minimum || value > maximum)
        {
            throw new ArgumentOutOfRangeException(
                name,
                value,
                string.Create(
                    CultureInfo.InvariantCulture,
                    $"{name} must be from {minimum:N0} to {maximum:N0}: {reason}."));
        }
    }
}
