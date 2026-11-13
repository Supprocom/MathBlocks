using System.Globalization;
using System.Reflection;
using System.Text;
using System.Text.Json;
using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockWindowTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Verifies, without a CUDA device, the validation of <see cref="MathBlocksCudaOptions"/>, the launch geometry the plan reports, its JSON shape and
/// the host sizing that depends on the block size. The device-limit checks take the limits as a value, so they run here too.
/// </summary>
public sealed class MathBlockCudaOptionsTests
{
    private const double Fill = -1d;
    private const string SlidingSource = "statistics.theil-sen-slope";

    private static readonly Assembly Library = typeof(MathBlockCudaDeviceModule).Assembly;

    private static readonly Type ProgramType = Library.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCUDAProgram", throwOnError: true)!;

    private static readonly Type ValidatorType = Library.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaOptionsValidator", throwOnError: true)!;

    private static readonly Type LimitsType = Library.GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaDeviceLimits", throwOnError: true)!;

    private static readonly MethodInfo PlanArenaFor = ProgramType.GetMethod("PlanArenaFor", BindingFlags.Static | BindingFlags.NonPublic)!;

    /// <summary>Gets the option names, each with one value outside its range.</summary>
    public static TheoryData<string, int> BelowOne => new()
    {
        { nameof(MathBlocksCudaOptions.BlockSize), 0 },
        { nameof(MathBlocksCudaOptions.BlockSize), -5 },
        { nameof(MathBlocksCudaOptions.MaximumGridX), 0 },
        { nameof(MathBlocksCudaOptions.MaximumGridX), -1 },
        { nameof(MathBlocksCudaOptions.FusedMaximumBlocks), 0 },
        { nameof(MathBlocksCudaOptions.FusedBlockSize), 0 },
    };

    /// <summary>Verifies the defaults are today's launch limits.</summary>
    [Fact]
    public void CUDAOptionsDefaultToTodaysLaunchLimits()
    {
        var options = MathBlocksCudaOptions.Default;
        Assert.Equal(128, options.BlockSize);
        Assert.Equal(65_535, options.MaximumGridX);
        Assert.Equal(256L * 1024 * 1024, options.WindowScratchBudgetBytes);
        Assert.Equal(4_096, options.FusedMaximumBlocks);
        Assert.Equal(256, options.FusedBlockSize);
        Assert.Equal(128, MathBlockCudaDeviceModule.VirtualLaneCount);
        Assert.Equal(MathBlockCudaDeviceModule.DispatcherBlockSize, MathBlockCudaDeviceModule.VirtualLaneCount);
    }

    /// <summary>Verifies the device ordinal and the fused row block default to today's values, are range-checked before any device call, and reach the limit catalog.</summary>
    [Fact]
    public void TheDeviceOrdinalAndTheFusedRowBlockAreRangeChecked()
    {
        Assert.Equal(0, MathBlocksCudaOptions.Default.DeviceOrdinal);
        Assert.Equal(8192, MathBlocksCudaOptions.Default.FusedRowBlock);
        var (program, inputs) = ElementwiseProgram(100);

        var ordinal = Assert.Throws<ArgumentOutOfRangeException>(() => new MathBlocksCUDAWorker().CompileWithOptions(
            program, new MathBlocksCudaOptions { DeviceOrdinal = -1 }, inputs));
        var rowBlock = Assert.Throws<ArgumentOutOfRangeException>(() => new MathBlocksCUDAWorker().CompileWithOptions(
            program, new MathBlocksCudaOptions { FusedRowBlock = 0 }, inputs));

        Assert.Equal(nameof(MathBlocksCudaOptions.DeviceOrdinal), ordinal.ParamName);
        Assert.Contains("cuDeviceGetCount", ordinal.Message, StringComparison.Ordinal);
        Assert.Equal(nameof(MathBlocksCudaOptions.FusedRowBlock), rowBlock.ParamName);
        var limits = MathBlockLimits.Resolve(new MathBlocksCudaOptions { DeviceOrdinal = 2, FusedRowBlock = 100 });
        Assert.Equal(2L, limits.Single(limit => string.Equals(limit.Name, "cuda.device-ordinal", StringComparison.Ordinal)).Value);
        Assert.Equal(100L, limits.Single(limit => string.Equals(limit.Name, "fused.row-block", StringComparison.Ordinal)).Value);
        Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockLimits.Resolve(new MathBlocksCudaOptions { DeviceOrdinal = -1 }));
    }

    /// <summary>Verifies a value below 1 throws before any device call, naming the option and the limit.</summary>
    [Theory]
    [MemberData(nameof(BelowOne))]
    public void CompileWithOptionsRejectsAValueBelowOne(string option, int value)
    {
        ArgumentException.ThrowIfNullOrEmpty(option);
        var options = option switch
        {
            nameof(MathBlocksCudaOptions.BlockSize) => new MathBlocksCudaOptions { BlockSize = value },
            nameof(MathBlocksCudaOptions.MaximumGridX) => new MathBlocksCudaOptions { MaximumGridX = value },
            nameof(MathBlocksCudaOptions.FusedMaximumBlocks) => new MathBlocksCudaOptions { FusedMaximumBlocks = value },
            _ => new MathBlocksCudaOptions { FusedBlockSize = value },
        };
        var (program, inputs) = ElementwiseProgram(100);

        var exception = Assert.Throws<ArgumentOutOfRangeException>(() => new MathBlocksCUDAWorker().CompileWithOptions(program, options, inputs));

        Assert.Equal(option, exception.ParamName);
        Assert.Equal((long)value, Convert.ToInt64(exception.ActualValue, CultureInfo.InvariantCulture));
        Assert.Contains($"MathBlocksCudaOptions.{option} is {value.ToString("N0", CultureInfo.InvariantCulture)}", exception.Message, StringComparison.Ordinal);
        Assert.Contains("must be at least 1", exception.Message, StringComparison.Ordinal);
    }

    /// <summary>Verifies the window scratch budget range: at most int.MaxValue, named as int byte offsets, and at least 1.</summary>
    [Theory]
    [InlineData(0L)]
    [InlineData(-1L)]
    [InlineData(int.MaxValue + 1L)]
    [InlineData(long.MaxValue)]
    public void CompileWithOptionsRejectsAWindowScratchBudgetOutsideItsRange(long budget)
    {
        var (program, inputs) = ElementwiseProgram(100);
        var options = new MathBlocksCudaOptions { WindowScratchBudgetBytes = budget };

        var exception = Assert.Throws<ArgumentOutOfRangeException>(() => new MathBlocksCUDAWorker().CompileWithOptions(program, options, inputs));

        Assert.Equal(nameof(MathBlocksCudaOptions.WindowScratchBudgetBytes), exception.ParamName);
        Assert.Contains($"WindowScratchBudgetBytes is {budget.ToString("N0", CultureInfo.InvariantCulture)}", exception.Message, StringComparison.Ordinal);
        if (budget > int.MaxValue)
        {
            Assert.Contains("at most 2,147,483,647 bytes", exception.Message, StringComparison.Ordinal);
            Assert.Contains("int byte offsets", exception.Message, StringComparison.Ordinal);
            Assert.Contains("thread * capacity", exception.Message, StringComparison.Ordinal);
        }
        else
        {
            Assert.Contains("at least 1 byte", exception.Message, StringComparison.Ordinal);
        }
    }

    /// <summary>Verifies the boundary values 1 and int.MaxValue pass the range checks.</summary>
    [Fact]
    public void TheRangeChecksAcceptTheBoundaryValues()
    {
        Validate(new MathBlocksCudaOptions { BlockSize = 1, MaximumGridX = 1, FusedMaximumBlocks = 1, FusedBlockSize = 1, WindowScratchBudgetBytes = 1 });
        Validate(new MathBlocksCudaOptions { WindowScratchBudgetBytes = int.MaxValue });
        Validate(MathBlocksCudaOptions.Default);
    }

    /// <summary>Verifies the device limits: each option up to the device value passes and one above throws, naming the attribute.</summary>
    [Theory]
    [InlineData(nameof(MathBlocksCudaOptions.BlockSize), "CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK", 1_024)]
    [InlineData(nameof(MathBlocksCudaOptions.FusedBlockSize), "CU_DEVICE_ATTRIBUTE_MAX_THREADS_PER_BLOCK", 1_024)]
    [InlineData(nameof(MathBlocksCudaOptions.MaximumGridX), "CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X", 70_000)]
    [InlineData(nameof(MathBlocksCudaOptions.FusedMaximumBlocks), "CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X", 70_000)]
    public void TheDeviceLimitsBoundBlockSizeAndGrid(string option, string attribute, int limit)
    {
        ArgumentException.ThrowIfNullOrEmpty(option);
        var device = CreateLimits(1_024, 70_000);

        ValidateDevice(WithOption(option, limit), device);
        var exception = Assert.Throws<ArgumentOutOfRangeException>(() => ValidateDevice(WithOption(option, limit + 1), device));

        Assert.Equal(option, exception.ParamName);
        Assert.Contains($"MathBlocksCudaOptions.{option} is {(limit + 1).ToString("N0", CultureInfo.InvariantCulture)}", exception.Message, StringComparison.Ordinal);
        Assert.Contains($"at most {limit.ToString("N0", CultureInfo.InvariantCulture)}", exception.Message, StringComparison.Ordinal);
        Assert.Contains(attribute, exception.Message, StringComparison.Ordinal);
    }

    /// <summary>Verifies a kernel's own thread limit is checked and named.</summary>
    [Fact]
    public void ACompiledKernelsOwnThreadLimitBoundsTheBlockSize()
    {
        var validate = ValidatorType.GetMethod("ValidateKernel", BindingFlags.Static | BindingFlags.NonPublic)!;
        object[] ok = [640, 640, nameof(MathBlocksCudaOptions.BlockSize), "Matrix", "matrix.multiply@1"];
        object[] over = [641, 640, nameof(MathBlocksCudaOptions.BlockSize), "Matrix", "matrix.multiply@1"];

        _ = validate.Invoke(null, ok);
        var exception = Assert.Throws<TargetInvocationException>(() => validate.Invoke(null, over));

        var range = Assert.IsType<ArgumentOutOfRangeException>(exception.InnerException);
        Assert.Contains("MathBlocksCudaOptions.BlockSize is 641", range.Message, StringComparison.Ordinal);
        Assert.Contains("kernel Matrix (matrix.multiply@1)", range.Message, StringComparison.Ordinal);
        Assert.Contains("at most 640 threads per block", range.Message, StringComparison.Ordinal);
        Assert.Contains("CU_FUNC_ATTRIBUTE_MAX_THREADS_PER_BLOCK", range.Message, StringComparison.Ordinal);
    }

    /// <summary>
    /// Verifies the budget minimum is the scratch of one block of the program's window form at the block size: that budget is accepted, one byte
    /// less throws naming the form and the bytes, and the minimum scales with the block size.
    /// </summary>
    [Theory]
    [InlineData(128)]
    [InlineData(7)]
    [InlineData(1)]
    [InlineData(256)]
    public void TheWindowScratchBudgetMustHoldOneBlockOfEachWindowForm(int blockSize)
    {
        var (program, inputs) = WindowProgram(SlidingSource, 1_000, 96);
        var unclamped = new MathBlocksCudaOptions { BlockSize = blockSize, WindowScratchBudgetBytes = int.MaxValue };
        var window = Assert.Single(Plan(program, inputs, unclamped, enforce: true).Launches);
        var minimum = window.ScratchBytesPerBlock;
        Assert.True(minimum > 0);
        Assert.Equal(0L, minimum % (8L * blockSize));

        _ = Plan(program, inputs, new MathBlocksCudaOptions { BlockSize = blockSize, WindowScratchBudgetBytes = minimum }, enforce: true);
        var exception = Assert.Throws<TargetInvocationException>(() =>
            Plan(program, inputs, new MathBlocksCudaOptions { BlockSize = blockSize, WindowScratchBudgetBytes = minimum - 1 }, enforce: true));

        var range = Assert.IsType<ArgumentOutOfRangeException>(exception.InnerException);
        Assert.Equal(nameof(MathBlocksCudaOptions.WindowScratchBudgetBytes), range.ParamName);
        Assert.Contains($"window.{SlidingSource}@1 needs at least {minimum.ToString("N0", CultureInfo.InvariantCulture)} bytes", range.Message, StringComparison.Ordinal);
        Assert.Contains($"{blockSize.ToString("N0", CultureInfo.InvariantCulture)} threads", range.Message, StringComparison.Ordinal);
    }

    /// <summary>Verifies the default planning path keeps a window form over the budget on one block, as before options existed.</summary>
    [Fact]
    public void CompileKeepsAWindowFormOverTheDefaultBudgetOnOneBlock()
    {
        // The pseudomedian at width 1,447 needs about 2.1 GB for one block of 128 threads: over the default budget, under int.MaxValue.
        var (program, inputs) = WindowProgram("statistics.pseudomedian", 1_500, 1_447);

        var plan = Plan(program, inputs, MathBlocksCudaOptions.Default, enforce: false);
        var launch = Assert.Single(plan.Launches);

        Assert.Equal(1, launch.Blocks);
        Assert.True(launch.ScratchBytesPerBlock > MathBlocksCudaOptions.Default.WindowScratchBudgetBytes);
        var exception = Assert.Throws<TargetInvocationException>(() => Plan(program, inputs, MathBlocksCudaOptions.Default, enforce: true));
        Assert.IsType<ArgumentOutOfRangeException>(exception.InnerException);
    }

    /// <summary>Verifies the elementwise grid follows the block size and MaximumGridX, with the blocks before the clamp reported.</summary>
    [Theory]
    [InlineData(128, 65_535, 8, 8, null)]
    [InlineData(7, 65_535, 143, 143, null)]
    [InlineData(1, 65_535, 1_000, 1_000, null)]
    [InlineData(1_024, 65_535, 1, 1, null)]
    [InlineData(7, 5, 5, 143, "MaximumGridX")]
    [InlineData(128, 1, 1, 8, "MaximumGridX")]
    [InlineData(128, 8, 8, 8, null)]
    public void ElementwiseLaunchesStripeTheRowsOverTheClampedGrid(int blockSize, int maximumGridX, int blocks, long wanted, string? clampedBy)
    {
        var (program, inputs) = ElementwiseProgram(1_000);
        var options = new MathBlocksCudaOptions { BlockSize = blockSize, MaximumGridX = maximumGridX };

        var launch = Assert.Single(Plan(program, inputs, options, enforce: true).Launches);

        Assert.Equal(new MathBlockCudaLaunch("elementwise.scalar.negate@1", launch.NodeIndex, blocks, blockSize, 0L, wanted, clampedBy), launch);
        Assert.Equal(2, launch.NodeIndex);
    }

    /// <summary>Verifies a window launch reports its scratch per block and which option cut the grid.</summary>
    [Fact]
    public void WindowLaunchesReportTheBlocksTheRowsCallForAndTheClampThatCutThem()
    {
        var (program, inputs) = WindowProgram(SlidingSource, 1_000, 96);
        var oneBlock = Assert.Single(Plan(program, inputs, new MathBlocksCudaOptions { WindowScratchBudgetBytes = int.MaxValue }, enforce: true).Launches);
        var blockBytes = oneBlock.ScratchBytesPerBlock;

        Assert.Equal(8, oneBlock.Blocks);
        Assert.Equal(8L, oneBlock.WantedBlocks);
        Assert.Null(oneBlock.ClampedBy);
        Assert.Equal(128, oneBlock.ThreadsPerBlock);

        var byGrid = Assert.Single(Plan(program, inputs, new MathBlocksCudaOptions { MaximumGridX = 3, WindowScratchBudgetBytes = int.MaxValue }, enforce: true).Launches);
        Assert.Equal((3, 8L, "MaximumGridX", blockBytes), (byGrid.Blocks, byGrid.WantedBlocks, byGrid.ClampedBy, byGrid.ScratchBytesPerBlock));

        var byBudget = Assert.Single(Plan(program, inputs, new MathBlocksCudaOptions { WindowScratchBudgetBytes = 2 * blockBytes + 1 }, enforce: true).Launches);
        Assert.Equal((2, 8L, "WindowScratchBudgetBytes", blockBytes), (byBudget.Blocks, byBudget.WantedBlocks, byBudget.ClampedBy, byBudget.ScratchBytesPerBlock));

        var both = Assert.Single(Plan(program, inputs, new MathBlocksCudaOptions { MaximumGridX = 3, WindowScratchBudgetBytes = blockBytes }, enforce: true).Launches);
        Assert.Equal((1, 8L, "WindowScratchBudgetBytes"), (both.Blocks, both.WantedBlocks, both.ClampedBy));
    }

    /// <summary>Verifies the window scratch of one block grows with the block size (one slice per thread).</summary>
    [Theory]
    [InlineData(1)]
    [InlineData(7)]
    [InlineData(100)]
    [InlineData(129)]
    [InlineData(1_024)]
    public void TheWindowScratchOfOneBlockIsOneSlicePerThread(int blockSize)
    {
        var (program, inputs) = WindowProgram(SlidingSource, 1_000, 96);
        var reference = Assert.Single(Plan(program, inputs, new MathBlocksCudaOptions { BlockSize = 1, WindowScratchBudgetBytes = int.MaxValue }, enforce: true).Launches);

        var launch = Assert.Single(Plan(program, inputs, new MathBlocksCudaOptions { BlockSize = blockSize, WindowScratchBudgetBytes = int.MaxValue }, enforce: true).Launches);

        Assert.Equal(reference.ScratchBytesPerBlock * blockSize, launch.ScratchBytesPerBlock);
        Assert.Equal(blockSize, launch.ThreadsPerBlock);
        Assert.Equal((1_000L + blockSize - 1) / blockSize, launch.WantedBlocks);
    }

    /// <summary>Verifies a family kernel is one block of the block size, the scalar family one thread, and the default is 128.</summary>
    [Theory]
    [InlineData(128)]
    [InlineData(1)]
    [InlineData(1_024)]
    public void FamilyKernelsLaunchOneBlockOfTheBlockSizeAndScalarsOneThread(int blockSize)
    {
        var options = new MathBlocksCudaOptions { BlockSize = blockSize };
        var (sumProgram, sumInputs) = SimpleProgram("vector.sum", [MathBlockValue.Vector(Enumerable.Range(0, 50).Select(value => value * 0.25d).ToArray())]);
        var (addProgram, addInputs) = SimpleProgram("scalar.add", [MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2d)]);

        var vector = Assert.Single(Plan(sumProgram, sumInputs, options, enforce: true).Launches);
        var scalar = Assert.Single(Plan(addProgram, addInputs, options, enforce: true).Launches);

        Assert.Equal(("vector.sum@1", 1, blockSize, 1L, 400L, null), (vector.Operation, vector.Blocks, vector.ThreadsPerBlock, vector.WantedBlocks, vector.ScratchBytesPerBlock, vector.ClampedBy));
        Assert.Equal(("scalar.add@1", 1, 1, 1L), (scalar.Operation, scalar.Blocks, scalar.ThreadsPerBlock, scalar.WantedBlocks));
    }

    /// <summary>Verifies the scratch of the rank radix sort holds 128 virtual lanes whatever the block size.</summary>
    [Theory]
    [InlineData(1)]
    [InlineData(32)]
    [InlineData(129)]
    [InlineData(1_024)]
    public void TheRollingOrderStatisticScratchDoesNotDependOnTheBlockSize(int blockSize)
    {
        var x = MathBlockValue.Vector(Enumerable.Range(0, 300).Select(index => (index * 37 % 101) * 0.5d).ToArray());
        var (program, inputs) = SimpleProgram("sequence.rolling-median", [x, MathBlockValue.Scalar(17d)]);

        var reference = Assert.Single(Plan(program, inputs, MathBlocksCudaOptions.Default, enforce: true).Launches);
        var launch = Assert.Single(Plan(program, inputs, new MathBlocksCudaOptions { BlockSize = blockSize }, enforce: true).Launches);

        Assert.Equal(reference.ScratchBytesPerBlock, launch.ScratchBytesPerBlock);
        var expected = 300L * 36 + 17L * 8 + MathBlockCudaDeviceModule.VirtualLaneCount * sizeof(int) * 2L;
        Assert.Equal(expected, launch.ScratchBytesPerBlock);
    }

    /// <summary>Verifies the largest window width of a scratch-limited form shrinks as the block size grows and the plan accepts it exactly.</summary>
    [Theory]
    [InlineData(128)]
    [InlineData(256)]
    [InlineData(1_024)]
    public void TheLargestWindowWidthFollowsTheBlockSize(int blockSize)
    {
        var maximumWidth = ReflectMaximumWidth("statistics.pseudomedian", blockSize);
        var options = new MathBlocksCudaOptions { BlockSize = blockSize, WindowScratchBudgetBytes = int.MaxValue };
        if (blockSize == 128)
            Assert.Equal(1_447L, maximumWidth);
        Assert.True(maximumWidth < ReflectMaximumWidth("statistics.pseudomedian", blockSize / 2));

        var (accepted, acceptedInputs) = WindowProgram("statistics.pseudomedian", (int)maximumWidth + 2, (int)maximumWidth);
        var (rejected, rejectedInputs) = WindowProgram("statistics.pseudomedian", (int)maximumWidth + 2, (int)maximumWidth + 1);
        _ = Plan(accepted, acceptedInputs, options, enforce: true);
        var exception = Assert.Throws<TargetInvocationException>(() => Plan(rejected, rejectedInputs, options, enforce: true));

        var invalid = Assert.IsType<InvalidOperationException>(exception.InnerException);
        Assert.Contains($"supports widths of at most {maximumWidth.ToString("N0", CultureInfo.InvariantCulture)}", invalid.Message, StringComparison.Ordinal);
    }

    /// <summary>Verifies the launches are written as a JSON array with stable field names and order.</summary>
    [Fact]
    public void LaunchesWriteAsJsonWithStableFieldsAndOrder()
    {
        MathBlockCudaLaunch[] launches =
        [
            new("window.statistics.theil-sen-slope@1", 3, 2, 128, 9_535_488, 8, "WindowScratchBudgetBytes"),
            new("vector.sum@1", 1, 1, 7, 0, 1, null),
            new("fused-expression", null, 4_096, 256, 0, 5_000, "FusedMaximumBlocks"),
        ];
        using var stream = new MemoryStream();
        using (var writer = new Utf8JsonWriter(stream))
            MathBlockCudaLaunch.WriteJson(writer, launches);

        var json = Encoding.UTF8.GetString(stream.ToArray());

        Assert.Equal(
            "[{\"operation\":\"window.statistics.theil-sen-slope@1\",\"nodeIndex\":3,\"blocks\":2,\"threadsPerBlock\":128,\"scratchBytesPerBlock\":9535488,\"wantedBlocks\":8,\"clampedBy\":\"WindowScratchBudgetBytes\"}," +
            "{\"operation\":\"vector.sum@1\",\"nodeIndex\":1,\"blocks\":1,\"threadsPerBlock\":7,\"scratchBytesPerBlock\":0,\"wantedBlocks\":1,\"clampedBy\":null}," +
            "{\"operation\":\"fused-expression\",\"nodeIndex\":null,\"blocks\":4096,\"threadsPerBlock\":256,\"scratchBytesPerBlock\":0,\"wantedBlocks\":5000,\"clampedBy\":\"FusedMaximumBlocks\"}]",
            json);
        using var empty = new MemoryStream();
        using (var writer = new Utf8JsonWriter(empty))
            MathBlockCudaLaunch.WriteJson(writer, []);
        Assert.Equal("[]", Encoding.UTF8.GetString(empty.ToArray()));
    }

    /// <summary>
    /// Verifies PlanCUDA for the dispatcher: the default block size gives the same plan as before, the window scratch is one slice per thread of the
    /// given block size, every other operation's scratch does not depend on it, and a block size below 1 is rejected.
    /// </summary>
    [Fact]
    public void PlanCUDASizesTheWindowScratchForTheBlockSizeAndNothingElse()
    {
        var series = CreateSourceInputs(SlidingSource, 1_000, 96, 11);
        var inputs = FormInputs(series, 96, FillFor(SlidingSource, series));
        var contract = MathBlockCudaDeviceModule.GetOperation($"window.{SlidingSource}@1");

        var plan128 = contract.PlanCUDA(inputs);
        var explicit128 = contract.PlanCUDA(inputs, MathBlockDomainOptions.Default, 128);
        var plan256 = contract.PlanCUDA(inputs, MathBlockDomainOptions.Default, 256);
        var plan1 = contract.PlanCUDA(inputs, MathBlockDomainOptions.Default, 1);

        Assert.Equal(plan128, explicit128);
        var perThreadBytes = ReflectScratchPerThreadBytes(SlidingSource, 96);
        Assert.Equal(perThreadBytes * 256 * 4, plan256.ScratchBytes);
        Assert.Equal(perThreadBytes * 1 * 1_000, plan1.ScratchBytes);

        var x = MathBlockValue.Vector(Enumerable.Range(0, 300).Select(index => (index * 37 % 101) * 0.5d).ToArray());
        var median = MathBlockCudaDeviceModule.GetOperation("sequence.rolling-median@1");
        MathBlockValue[] medianInputs = [x, MathBlockValue.Scalar(17d)];
        var baseline = median.PlanCUDA(medianInputs);
        foreach (var blockSize in new[] { 1, 33, 1_024 })
            Assert.Equal(baseline, median.PlanCUDA(medianInputs, MathBlockDomainOptions.Default, blockSize));

        Assert.Throws<ArgumentOutOfRangeException>(() => contract.PlanCUDA(inputs, MathBlockDomainOptions.Default, 0));
        Assert.Throws<ArgumentNullException>(() => contract.PlanCUDA(inputs, null!, 128));
        Assert.Throws<ArgumentOutOfRangeException>(() => contract.PlanCUDA(inputs, new MathBlockDomainOptions { MaximumStateCount = 0 }, 128));
    }

    /// <summary>Verifies CompileWithOptions rejects a domain option outside its range before it touches a CUDA device.</summary>
    [Fact]
    public void CompileWithOptionsRejectsADomainOptionOutsideItsRange()
    {
        var (program, inputs) = ElementwiseProgram(10);

        var thrown = Assert.Throws<ArgumentOutOfRangeException>(() => new MathBlocksCUDAWorker().CompileWithOptions(
            program,
            MathBlocksCudaOptions.Default,
            inputs,
            new MathBlockDomainOptions { MaximumExplicitSubsetSize = 27 }));

        Assert.Contains("MaximumExplicitSubsetSize", thrown.Message, StringComparison.Ordinal);
        Assert.Contains("26", thrown.Message, StringComparison.Ordinal);
    }

    private static (MathBlockProgram Program, Dictionary<string, MathBlockValue> Inputs) WindowProgram(string source, int count, int width)
    {
        var series = CreateSourceInputs(source, count, width, 11);
        var values = FormInputs(series, width, FillFor(source, series));
        var builder = new MathBlockProgramBuilder(Windowed);
        var form = Form(source);
        var nodes = values.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(form.Identifier, form.Version, nodes)).Build();
        return (program, Name(values));
    }

    private static (MathBlockProgram Program, Dictionary<string, MathBlockValue> Inputs) ElementwiseProgram(int count)
    {
        var values = new MathBlockValue[]
        {
            MathBlockValue.Vector(Enumerable.Range(0, count).Select(index => index * 0.5d - 3d).ToArray()),
            MathBlockValue.Scalar(Fill),
        };
        return SimpleProgram("elementwise.scalar.negate", values);
    }

    private static (MathBlockProgram Program, Dictionary<string, MathBlockValue> Inputs) SimpleProgram(string identifier, MathBlockValue[] values)
    {
        var operation = MathBlockCatalog.Standard.Get(identifier);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = values.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
        return (program, Name(values));
    }

    private static Dictionary<string, MathBlockValue> Name(MathBlockValue[] values) =>
        values.Select((input, index) => (Name: $"input-{index}", Input: input)).ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);

    private static MathBlockValue FillFor(string source, MathBlockValue[] series) =>
        MathBlockValue.Scalar(
            Fill,
            Form(source).ResolveOutputType(
                [.. series.Select(input => input.Type), MathBlockType.Scalar(), MathBlockType.Scalar()]).Unit);

    // The planning of CompileWithOptions up to its first device call; the result's Launches is the launch geometry.
    private static PlanResult Plan(MathBlockProgram program, Dictionary<string, MathBlockValue> inputs, MathBlocksCudaOptions options, bool enforce)
    {
        var plan = PlanArenaFor.Invoke(null, [program, inputs, options, MathBlockDomainOptions.Default, enforce])!;
        var launches = (IReadOnlyList<MathBlockCudaLaunch>)plan.GetType().GetProperty("Launches")!.GetValue(plan)!;
        return new PlanResult(launches);
    }

    private static void Validate(MathBlocksCudaOptions options)
    {
        var validate = ValidatorType.GetMethod("ValidateRanges", BindingFlags.Static | BindingFlags.NonPublic)!;
        _ = validate.Invoke(null, [options]);
    }

    private static void ValidateDevice(MathBlocksCudaOptions options, object limits)
    {
        var validate = ValidatorType.GetMethod("ValidateDevice", BindingFlags.Static | BindingFlags.NonPublic)!;
        try
        {
            _ = validate.Invoke(null, [options, limits]);
        }
        catch (TargetInvocationException exception) when (exception.InnerException is not null)
        {
            throw exception.InnerException;
        }
    }

    private static object CreateLimits(int threads, int grid) => Activator.CreateInstance(LimitsType, threads, grid)!;

    private static MathBlocksCudaOptions WithOption(string option, int value) => option switch
    {
        nameof(MathBlocksCudaOptions.BlockSize) => new MathBlocksCudaOptions { BlockSize = value },
        nameof(MathBlocksCudaOptions.FusedBlockSize) => new MathBlocksCudaOptions { FusedBlockSize = value },
        nameof(MathBlocksCudaOptions.MaximumGridX) => new MathBlocksCudaOptions { MaximumGridX = value },
        _ => new MathBlocksCudaOptions { FusedMaximumBlocks = value },
    };

    private static long ReflectMaximumWidth(string source, int blockSize)
    {
        var catalog = Library.GetType("Supprocom.MathBlocks.Cuda.WindowCudaBlockCatalog", throwOnError: true)!;
        var resolve = catalog.GetMethod("Resolve", BindingFlags.Static | BindingFlags.NonPublic)!;
        var opcode = Opcode(resolve.Invoke(null, [$"window.{source}@1"])!);
        var maximum = catalog.GetMethod("MaximumWidth", BindingFlags.Static | BindingFlags.NonPublic, [typeof(int), typeof(int)])!;
        return (long)maximum.Invoke(null, [opcode / 2, blockSize])!;
    }

    // The doubles of scratch one thread of a window form owns for a width, times 8.
    private static long ReflectScratchPerThreadBytes(string source, long width)
    {
        var catalog = Library.GetType("Supprocom.MathBlocks.Cuda.WindowCudaBlockCatalog", throwOnError: true)!;
        var resolve = catalog.GetMethod("Resolve", BindingFlags.Static | BindingFlags.NonPublic)!;
        var opcode = Opcode(resolve.Invoke(null, [$"window.{source}@1"])!);
        var doubles = (long)catalog.GetMethod("ScratchDoubles", BindingFlags.Static | BindingFlags.NonPublic)!.Invoke(null, [opcode / 2, width])!;
        return doubles * sizeof(double);
    }

    private static int Opcode(object feature) => (int)feature.GetType().GetProperty("Opcode")!.GetValue(feature)!;

    private sealed record PlanResult(IReadOnlyList<MathBlockCudaLaunch> Launches);
}
