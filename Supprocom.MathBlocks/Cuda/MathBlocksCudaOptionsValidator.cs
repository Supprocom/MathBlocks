using System.Globalization;

namespace Supprocom.MathBlocks.Cuda;

// Checks MathBlocksCudaOptions at compile. Each failure is an ArgumentOutOfRangeException that names the option, the value, the
// limit it broke and where the limit comes from. The range checks need no device; the device checks take the device limits as
// a value, so they run without one.
internal static class MathBlocksCudaOptionsValidator
{
    private const string BudgetOption = nameof(MathBlocksCudaOptions.WindowScratchBudgetBytes);

    // The domain options of a program; null is the defaults. An option outside its range throws ArgumentOutOfRangeException.
    internal static MathBlockDomainOptions RequireDomain(MathBlockDomainOptions? domainOptions)
    {
        var domain = domainOptions ?? MathBlockDomainOptions.Default;
        domain.Validate();
        return domain;
    }

    // The checks that need nothing but the options.
    internal static void ValidateRanges(MathBlocksCudaOptions options)
    {
        ArgumentNullException.ThrowIfNull(options);
        AtLeastOne(options.BlockSize, nameof(MathBlocksCudaOptions.BlockSize), "a launch needs at least one thread per block");
        AtLeastOne(options.MaximumGridX, nameof(MathBlocksCudaOptions.MaximumGridX), "a launch needs at least one block");
        AtLeastOne(options.FusedMaximumBlocks, nameof(MathBlocksCudaOptions.FusedMaximumBlocks), "a launch needs at least one block");
        AtLeastOne(options.FusedBlockSize, nameof(MathBlocksCudaOptions.FusedBlockSize), "a launch needs at least one thread per block");
        AtLeastOne(options.FusedRowBlock, nameof(MathBlocksCudaOptions.FusedRowBlock), "a task evaluates at least one row");
        if (options.DeviceOrdinal < 0)
        {
            throw Range(
                nameof(MathBlocksCudaOptions.DeviceOrdinal),
                options.DeviceOrdinal,
                $"MathBlocksCudaOptions.DeviceOrdinal is {Format(options.DeviceOrdinal)}; it must be at least 0, and below the number of CUDA devices that cuDeviceGetCount reports.");
        }
        if (options.WindowScratchBudgetBytes > int.MaxValue)
        {
            throw Range(
                BudgetOption,
                options.WindowScratchBudgetBytes,
                $"MathBlocksCudaOptions.{BudgetOption} is {Format(options.WindowScratchBudgetBytes)}; it must be at most {Format(int.MaxValue)} bytes: " +
                "the scratch of a launch is addressed with int byte offsets (the program arena offsets and the window kernel's per-thread slice index, thread * capacity).");
        }
        if (options.WindowScratchBudgetBytes < 1)
        {
            throw Range(
                BudgetOption,
                options.WindowScratchBudgetBytes,
                $"MathBlocksCudaOptions.{BudgetOption} is {Format(options.WindowScratchBudgetBytes)}; it must be at least 1 byte, and at least the scratch of one block of each window form in the program.");
        }
    }

    // The checks against the device limits.
    internal static void ValidateDevice(MathBlocksCudaOptions options, MathBlockCudaDeviceLimits device)
    {
        ArgumentNullException.ThrowIfNull(options);
        AtMost(
            options.BlockSize,
            device.MaximumThreadsPerBlock,
            nameof(MathBlocksCudaOptions.BlockSize),
            "threads per block",
            "CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK of this CUDA device");
        AtMost(
            options.FusedBlockSize,
            device.MaximumThreadsPerBlock,
            nameof(MathBlocksCudaOptions.FusedBlockSize),
            "threads per block",
            "CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK of this CUDA device");
        AtMost(
            options.MaximumGridX,
            device.MaximumGridX,
            nameof(MathBlocksCudaOptions.MaximumGridX),
            "blocks in grid X",
            "CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X of this CUDA device");
        AtMost(
            options.FusedMaximumBlocks,
            device.MaximumGridX,
            nameof(MathBlocksCudaOptions.FusedMaximumBlocks),
            "blocks in grid X",
            "CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X of this CUDA device");
    }

    // A compiled kernel can have a lower limit than the device (its register use): CU_FUNC_ATTRIBUTE_MAX_THREADS_PER_BLOCK.
    internal static void ValidateKernel(int blockSize, int kernelMaximum, string optionName, string kernel, string users)
    {
        if (blockSize <= kernelMaximum)
            return;
        throw Range(
            optionName,
            blockSize,
            $"MathBlocksCudaOptions.{optionName} is {Format(blockSize)}; the compiled kernel {kernel} ({users}) launches at most {Format(kernelMaximum)} threads per block on this CUDA device " +
            "(CU_FUNC_ATTRIBUTE_MAX_THREADS_PER_BLOCK, which its register use sets).");
    }

    // One block of a window form needs scratchPerThread doubles for each of its blockSize threads, and a launch needs one block.
    internal static void ValidateWindowBudget(
        MathBlocksCudaOptions options,
        string identity,
        long scratchDoublesPerThread,
        long blockBytes)
    {
        if (options.WindowScratchBudgetBytes >= blockBytes)
            return;
        throw Range(
            BudgetOption,
            options.WindowScratchBudgetBytes,
            $"MathBlocksCudaOptions.{BudgetOption} is {Format(options.WindowScratchBudgetBytes)}; {identity} needs at least {Format(blockBytes)} bytes: one block of " +
            $"{Format(options.BlockSize)} threads with {Format(scratchDoublesPerThread)} doubles of scratch each, and a launch needs at least one block.");
    }

    // An ordinal outside 0 to the device count minus one; the message names the count the driver reports.
    internal static ArgumentOutOfRangeException DeviceOrdinalOutOfRange(int ordinal, int count) =>
        Range(
            nameof(MathBlocksCudaOptions.DeviceOrdinal),
            ordinal,
            $"MathBlocksCudaOptions.DeviceOrdinal must be from 0 to {Format(count - 1L)}: cuDeviceGetCount reports {Format(count)} CUDA device(s) and the ordinal is {Format(ordinal)}.");

    private static void AtLeastOne(long value, string option, string cause)
    {
        if (value >= 1)
            return;
        throw Range(option, value, $"MathBlocksCudaOptions.{option} is {Format(value)}; it must be at least 1: {cause}.");
    }

    private static void AtMost(long value, long limit, string option, string unit, string source)
    {
        if (value <= limit)
            return;
        throw Range(option, value, $"MathBlocksCudaOptions.{option} is {Format(value)}; it must be at most {Format(limit)} {unit}: {source}.");
    }

    private static ArgumentOutOfRangeException Range(string option, long value, string message) =>
        new(option, value, message);

    private static string Format(long value) => value.ToString("N0", CultureInfo.InvariantCulture);
}
