namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Blocks CUDAWorker contract.</summary>
public sealed class MathBlocksCUDAWorker
{
    /// <summary>Gets whether the CUDA runtime and a compatible device are available.</summary>
    public static bool IsAvailable => MathBlocksCudaNative.IsAvailable();
    /// <summary>Gets the supported block identities value.</summary>
    public static IReadOnlyCollection<string> SupportedBlockIdentities =>
        MathBlocksCudaKernelModule.SupportedBlockIdentities;

    /// <summary>Compiles a typed program into a resident CUDA program.</summary>
    public MathBlocksCUDAProgram Compile(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs = null)
    {
        ArgumentNullException.ThrowIfNull(program);
        return MathBlocksCUDAProgram.Create(program, prototypeInputs);
    }

    /// <summary>Compiles a typed program into a resident CUDA program with the given launch options.</summary>
    /// <remarks>
    /// Every option is checked before the program is built, and an out-of-range value throws an <see cref="ArgumentOutOfRangeException"/> whose
    /// message names the limit and its cause: a value below 1; <see cref="MathBlocksCudaOptions.BlockSize"/> and
    /// <see cref="MathBlocksCudaOptions.FusedBlockSize"/> above the device maximum threads per block (and <see cref="MathBlocksCudaOptions.BlockSize"/>
    /// above the maximum of any compiled kernel the program launches); <see cref="MathBlocksCudaOptions.MaximumGridX"/> and
    /// <see cref="MathBlocksCudaOptions.FusedMaximumBlocks"/> above the device maximum grid X; <see cref="MathBlocksCudaOptions.WindowScratchBudgetBytes"/>
    /// above <see cref="int.MaxValue"/> (the scratch is addressed with int byte offsets) or below the scratch of one block of a window form of the program.
    /// <see cref="Compile"/> uses <see cref="MathBlocksCudaOptions.Default"/>.
    /// </remarks>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range the CUDA device or the program allows.</exception>
    public MathBlocksCUDAProgram CompileWithOptions(
        MathBlockProgram program,
        MathBlocksCudaOptions options,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs = null,
        MathBlockDomainOptions? domainOptions = null)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(options);
        var domain = MathBlocksCudaOptionsValidator.RequireDomain(domainOptions);
        return MathBlocksCUDAProgram.CreateWithOptions(program, prototypeInputs, options, domain);
    }

    /// <summary>Plans scratch work for a rolling order-statistic operation.</summary>
    public MathBlockRollingOrderStatisticWorkPlan PlanRollingOrderStatisticWork(
        int inputCount,
        int windowWidth,
        double probability)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(inputCount);
        if (windowWidth <= 0 || windowWidth > inputCount)
            throw new ArgumentOutOfRangeException(nameof(windowWidth));
        if (!double.IsFinite(probability) || probability is < 0d or > 1d)
            throw new ArgumentOutOfRangeException(nameof(probability));
        var outputCount = checked(inputCount - windowWidth + 1);
        if (windowWidth == 1)
        {
            return new MathBlockRollingOrderStatisticWorkPlan(
                inputCount,
                windowWidth,
                outputCount,
                probability,
                false,
                false,
                0,
                inputCount,
                0,
                0,
                inputCount);
        }
        if (probability is 0d or 1d)
        {
            var linearBound = checked((long)inputCount * 3);
            return new MathBlockRollingOrderStatisticWorkPlan(
                inputCount,
                windowWidth,
                outputCount,
                probability,
                true,
                false,
                0,
                linearBound,
                0,
                outputCount,
                checked(linearBound + outputCount));
        }
        var heapHeight = 1;
        for (var value = windowWidth; value > 1; value = (value + 1) >> 1)
            heapHeight++;
        var radixVisits = checked((long)inputCount * 64);
        var heapOperations = outputCount == 1
            ? 0
            : checked(
                ((long)windowWidth + checked(2L * (inputCount - windowWidth))) * heapHeight);
        var selectionOperations = checked((long)outputCount * 2);
        return new MathBlockRollingOrderStatisticWorkPlan(
            inputCount,
            windowWidth,
            outputCount,
            probability,
            false,
            true,
            64,
            radixVisits,
            heapOperations,
            selectionOperations,
            checked(radixVisits + heapOperations + selectionOperations));
    }

}
