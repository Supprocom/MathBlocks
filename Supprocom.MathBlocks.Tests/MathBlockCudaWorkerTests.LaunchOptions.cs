using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

// CoreCLR/CUDA parity under the launch options of MathBlocksCudaOptions: the CUDA result is bit for bit the CoreCLR result at every block size,
// at a grid clamped to 1 and 7 blocks, and at the smallest window scratch budget that holds one block. The device runs these; without one
// they fail at their first line like the other CUDA tests.
public sealed partial class MathBlockCudaWorkerTests
{
    private static readonly string[] LaunchWindowSources =
    [
        "vector.median", "vector.quantile", "statistics.theil-sen-slope", "statistics.pseudomedian",
        "statistics.distance-correlation", "statistics.kendall-tau-b", "vector.sum", "path.total-variation"
    ];

    private static readonly string[] LaunchElementwiseSources = ["scalar.negate", "scalar.maximum", "scalar.logit", "scalar.clamp", "probability.poisson-pmf"];

    /// <summary>Gets the names of the launch option sets: block sizes 1, 7, 32, 100, 129, 256 and the device maximum, grids of 1 and 7 blocks, both together, and the smallest scratch budget.</summary>
    public static TheoryData<string> LaunchOptionSets =>
    [
        "block-1", "block-7", "block-32", "block-100", "block-129", "block-256", "block-device-maximum",
        "grid-1", "grid-7", "block-7-grid-3", "block-1-grid-1", "minimum-budget"
    ];

    /// <summary>Verifies the window forms and siblings, including the sliding median, quantile and accurate sources, match CoreCLR under the option set.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "LaunchOptions")]
    [MemberData(nameof(LaunchOptionSets))]
    public void CUDAWindowFormsMatchCoreCLRUnderLaunchOptions(string optionSet)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var cases = new List<WindowCase>();
        foreach (var source in LaunchWindowSources)
            cases.AddRange(CreateWindowCases(source));
        cases.AddRange(CreateAccurateCases().Where(item =>
            (item.Operation.Identity.Contains("sample-variance", StringComparison.Ordinal) ||
             item.Operation.Identity.Contains("accurate.mean", StringComparison.Ordinal) ||
             item.Operation.Identity.Contains("vector.median", StringComparison.Ordinal) ||
             item.Operation.Identity.Contains("vector.quantile", StringComparison.Ordinal)) &&
            (item.Name.StartsWith("random", StringComparison.Ordinal) || item.Name.StartsWith("equal-runs", StringComparison.Ordinal) ||
             item.Name.StartsWith("out-of-range", StringComparison.Ordinal) || item.Name.StartsWith("regression", StringComparison.Ordinal))));
        var failures = new List<string>();
        foreach (ref readonly var windowCase in System.Runtime.InteropServices.CollectionsMarshal.AsSpan(cases))
        {
            var coreclr = windowCase.Operation.Evaluate(windowCase.Inputs);
            var cuda = ExecuteWithLaunchOptions(
                MathBlockWindowTestSupport.Windowed, windowCase.Operation, windowCase.Prototype, windowCase.Inputs, optionSet);
            if (DescribeWindowDifference(coreclr, cuda) is { } difference)
                failures.Add($"{windowCase.Operation.Identity}/{windowCase.Name}: {difference}");
        }

        Assert.True(failures.Count == 0, $"{optionSet}: {failures.Count} of {cases.Count} cases differ. {string.Join(Environment.NewLine, failures.Take(40))}");
        Assert.True(cases.Count >= LaunchWindowSources.Length * 17, $"Only {cases.Count} window cases ran.");
    }

    /// <summary>Verifies the elementwise forms and siblings, which stripe one row per thread over the clamped grid, match CoreCLR under the option set.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "LaunchOptions")]
    [MemberData(nameof(LaunchOptionSets))]
    public void CUDAElementwiseFormsMatchCoreCLRUnderLaunchOptions(string optionSet)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var failures = new List<string>();
        var caseCount = 0;
        foreach (var source in LaunchElementwiseSources)
        {
            foreach (var elementwiseCase in CreateElementwiseCases(source))
            {
                caseCount++;
                var coreclr = elementwiseCase.Operation.Evaluate(elementwiseCase.Inputs);
                var cuda = ExecuteWithLaunchOptions(
                    MathBlockCatalog.Standard,
                    elementwiseCase.Operation,
                    elementwiseCase.Prototype ?? elementwiseCase.Inputs,
                    elementwiseCase.Inputs,
                    optionSet);
                if (DescribeWindowDifference(coreclr, cuda) is { } difference)
                    failures.Add($"{elementwiseCase.Operation.Identity}/{elementwiseCase.Name}: {difference}");
            }
        }

        Assert.True(failures.Count == 0, $"{optionSet}: {failures.Count} of {caseCount} cases differ. {string.Join(Environment.NewLine, failures.Take(40))}");
        Assert.True(caseCount >= LaunchElementwiseSources.Length * 12, $"Only {caseCount} elementwise cases ran.");
    }

    /// <summary>Verifies the rolling median and quantile, whose rank radix sort runs on 128 virtual lanes, match CoreCLR under the option set.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "LaunchOptions")]
    [MemberData(nameof(LaunchOptionSets))]
    public void CUDARollingMedianAndQuantileMatchCoreCLRUnderLaunchOptions(string optionSet)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var failures = new List<string>();
        var caseCount = 0;
        foreach (var count in new[] { 5, 127, 129, 300, 1_031 })
        {
            var x = MathBlockValue.Vector(CreateRadixSeries(count));
            foreach (var width in new[] { 2, 3, 17, 100 }.Where(width => width <= count))
            {
                foreach (var (identity, extra) in new (string, double[])[]
                         {
                             ("sequence.rolling-median", []),
                             ("sequence.rolling-quantile", [0.25d]),
                             ("sequence.rolling-quantile", [0.9d]),
                             ("sequence.rolling-quantile", [0d]),
                             ("sequence.rolling-quantile", [1d]),
                         })
                {
                    MathBlockValue[] inputs = [x, MathBlockValue.Scalar(width), .. extra.Select(value => MathBlockValue.Scalar(value))];
                    var operation = MathBlockCatalog.Standard.Get(identity);
                    caseCount++;
                    var coreclr = operation.Evaluate(inputs);
                    var cuda = ExecuteWithLaunchOptions(MathBlockCatalog.Standard, operation, inputs, inputs, optionSet);
                    if (!IsExact(coreclr, cuda))
                        failures.Add($"{identity} n={count} w={width} {string.Join(',', extra)}: CoreCLR={DescribeBits(coreclr)}, CUDA={DescribeBits(cuda)}");
                }
            }
        }

        Assert.True(failures.Count == 0, $"{optionSet}: {failures.Count} of {caseCount} cases differ. {string.Join(Environment.NewLine, failures.Take(20))}");
    }

    /// <summary>Verifies the distance correlation, whose three moments and two totals are each summed serially by one chosen thread, matches CoreCLR under the option set.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "LaunchOptions")]
    [MemberData(nameof(LaunchOptionSets))]
    public void CUDADistanceCorrelationMatchesCoreCLRUnderLaunchOptions(string optionSet)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var operation = MathBlockCatalog.Standard.Get("statistics.distance-correlation");
        var failures = new List<string>();
        foreach (var count in new[] { 1, 2, 3, 4, 31, 129, 200 })
        {
            var random = new Random(5_000 + count);
            var x = MathBlockValue.Vector(Enumerable.Range(0, count).Select(_ => Math.Round(random.NextDouble() * 20d - 10d, 2, MidpointRounding.ToEven)).ToArray());
            var y = MathBlockValue.Vector(Enumerable.Range(0, count).Select(_ => random.NextDouble() * 4d).ToArray());
            MathBlockValue[] inputs = [x, y];
            var coreclr = operation.Evaluate(inputs);
            var cuda = ExecuteWithLaunchOptions(MathBlockCatalog.Standard, operation, inputs, inputs, optionSet);
            if (!IsExact(coreclr, cuda))
                failures.Add($"n={count}: CoreCLR={DescribeBits(coreclr)}, CUDA={DescribeBits(cuda)}");
        }

        Assert.True(failures.Count == 0, $"{optionSet}: {string.Join("; ", failures)}");
    }

    /// <summary>Verifies the compiled program reports the geometry its options call for, and that a clamp is named.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "LaunchOptions")]
    [InlineData(7, 3, 143, 3, "MaximumGridX")]
    [InlineData(100, 65_535, 10, 10, null)]
    [InlineData(1, 1, 1_000, 1, "MaximumGridX")]
    public void CUDAProgramsReportTheirLaunchGeometry(int blockSize, int maximumGridX, long wanted, int blocks, string? clampedBy)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var input = builder.Input("input-0", MathBlockType.Vector(length: 1_000));
        var fill = builder.Input("input-1", MathBlockType.Scalar());
        var program = builder.Output("result", builder.Apply("elementwise.scalar.negate", 1, [input, fill])).Build();
        var prototype = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["input-0"] = MathBlockValue.Vector(Enumerable.Range(0, 1_000).Select(index => index * 0.5d).ToArray()),
            ["input-1"] = MathBlockValue.Scalar(-1d),
        };
        var options = new MathBlocksCudaOptions { BlockSize = blockSize, MaximumGridX = maximumGridX };

        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, options, prototype);

        Assert.Same(options, compiled.Options);
        var launch = Assert.Single(compiled.Launches);
        Assert.Equal(("elementwise.scalar.negate@1", blocks, blockSize, wanted, clampedBy), (launch.Operation, launch.Blocks, launch.ThreadsPerBlock, launch.WantedBlocks, launch.ClampedBy));
    }

    // Keys with duplicates, both zeros and a wide range: ties and signed zeros exercise the radix sort's stability.
    private static double[] CreateRadixSeries(int count)
    {
        var random = new Random(900 + count);
        var values = new double[count];
        for (var index = 0; index < count; index++)
        {
            values[index] = random.Next(6) switch
            {
                0 => -0d,
                1 => 0d,
                2 => random.Next(-3, 4),
                3 => Math.Round(random.NextDouble() * 10d, 1, MidpointRounding.ToEven),
                4 => -1e-300 * random.Next(1, 5),
                _ => random.NextDouble() * 1e6 - 5e5,
            };
        }
        return values;
    }

    // Compiles the operation with CompileWithOptions for the named option set and runs it on the inputs. The program's own launches are checked
    // against the option set: the block size of every kernel but the scalar family, and a grid within MaximumGridX.
    private static MathBlockValue ExecuteWithLaunchOptions(
        MathBlockRegistry registry,
        MathBlockOperation operation,
        MathBlockValue[] prototype,
        MathBlockValue[] inputs,
        string optionSet)
    {
        var program = BuildSingleOperationProgram(registry, operation, prototype);
        var named = NameWindowInputs(prototype);
        var options = CreateLaunchOptions(optionSet, program, named);
        using var compiled = CompileForOptionSet(optionSet, program, named, ref options);
        foreach (var launch in compiled.Launches)
        {
            Assert.True(launch.Blocks >= 1 && launch.Blocks <= options.MaximumGridX, $"{optionSet}: {launch.Operation} launched {launch.Blocks} blocks.");
            Assert.True(
                launch.ThreadsPerBlock == options.BlockSize || launch.ThreadsPerBlock == 1,
                $"{optionSet}: {launch.Operation} launched {launch.ThreadsPerBlock} threads per block.");
            Assert.True(launch.Blocks == launch.WantedBlocks || launch.ClampedBy is not null, $"{optionSet}: {launch.Operation} lost blocks without naming a clamp.");
        }
        return compiled.Execute(NameWindowInputs(inputs))["result"];
    }

    // Compiles with the options. For "block-device-maximum" the block size is the device's maximum, which a kernel whose register use limits it
    // below that rejects at compile time with an ArgumentOutOfRangeException that names the kernel and its own maximum; the test checks that error
    // and compiles again at the kernel maximum the error names (once per kernel that is limited), so the case compares the largest launch the program allows.
    private static MathBlocksCUDAProgram CompileForOptionSet(
        string optionSet,
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue> prototype,
        ref MathBlocksCudaOptions options)
    {
        for (var attempt = 0; ; attempt++)
        {
            try
            {
                return new MathBlocksCUDAWorker().CompileWithOptions(program, options, prototype);
            }
            catch (ArgumentOutOfRangeException exception) when (string.Equals(optionSet, "block-device-maximum", StringComparison.Ordinal) && attempt < 8)
            {
                Assert.Contains("the compiled kernel ", exception.Message, StringComparison.Ordinal);
                Assert.Contains($"MathBlocksCudaOptions.{nameof(MathBlocksCudaOptions.BlockSize)} is", exception.Message, StringComparison.Ordinal);
                var maximum = MathBlockKernelMaximumMessage.Parse(exception.Message);
                Assert.True(maximum >= 1 && maximum < options.BlockSize, $"{optionSet}: kernel maximum {maximum} is not below the block size {options.BlockSize}.");
                options = new MathBlocksCudaOptions { BlockSize = maximum, WindowScratchBudgetBytes = options.WindowScratchBudgetBytes };
            }
        }
    }

    // The option set "block-device-maximum" sets the window scratch budget to its maximum as well, so that the block-size limit of the kernel,
    // not the budget, is the limit the compile reaches. The budget's own load-time error is checked separately with the default budget.
    private static MathBlocksCudaOptions CreateLaunchOptions(
        string optionSet,
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue> prototype)
    {
        switch (optionSet)
        {
            case "block-device-maximum":
                return new MathBlocksCudaOptions { BlockSize = DeviceMaximumThreadsPerBlock(), WindowScratchBudgetBytes = int.MaxValue };
            case "grid-1":
                return new MathBlocksCudaOptions { MaximumGridX = 1 };
            case "grid-7":
                return new MathBlocksCudaOptions { MaximumGridX = 7 };
            case "block-7-grid-3":
                return new MathBlocksCudaOptions { BlockSize = 7, MaximumGridX = 3 };
            case "block-1-grid-1":
                return new MathBlocksCudaOptions { BlockSize = 1, MaximumGridX = 1 };
            case "minimum-budget":
                // The scratch of one block of each window form: the largest ScratchBytesPerBlock of the program, or 1 when it has none.
                using (var probe = new MathBlocksCUDAWorker().Compile(program, prototype))
                    return new MathBlocksCudaOptions { WindowScratchBudgetBytes = Math.Max(1L, probe.Launches.Max(launch => launch.ScratchBytesPerBlock)) };
            default:
                var size = int.Parse(optionSet["block-".Length..], System.Globalization.CultureInfo.InvariantCulture);
                return new MathBlocksCudaOptions { BlockSize = size };
        }
    }

    /// <summary>
    /// Verifies each load-time error of the device maximum block for a window form on its own input. The device maximum exceeds the compiled kernel's own maximum
    /// (its register use), so with a large budget the error names BlockSize and that kernel maximum; at the kernel's maximum with a budget one byte under
    /// the scratch of one block the error names the budget.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "LaunchOptions")]
    public void DeviceMaximumBlockNamesTheKernelMaximumAndTheKernelMaximumBlockNamesTheBudget()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var windowCase = CreateWindowCases("vector.median").First();
        var program = BuildSingleOperationProgram(MathBlockWindowTestSupport.Windowed, windowCase.Operation, windowCase.Prototype);
        var inputs = NameWindowInputs(windowCase.Prototype);

        // (a) Only the kernel maximum check can fail: the budget is the largest the options allow.
        var deviceMaximum = DeviceMaximumThreadsPerBlock();
        var first = Assert.Throws<ArgumentOutOfRangeException>(() => new MathBlocksCUDAWorker().CompileWithOptions(
            program, new MathBlocksCudaOptions { BlockSize = deviceMaximum, WindowScratchBudgetBytes = int.MaxValue }, inputs));
        Assert.Equal(nameof(MathBlocksCudaOptions.BlockSize), first.ParamName);
        const string marker = "launches at most ";
        var start = first.Message.IndexOf(marker, StringComparison.Ordinal);
        Assert.True(start >= 0, first.Message);
        var digits = new string([.. first.Message[(start + marker.Length)..].TakeWhile(character => char.IsDigit(character) || character == ',')
            .Where(char.IsDigit)]);
        var kernelMaximum = int.Parse(digits, System.Globalization.CultureInfo.InvariantCulture);
        Assert.InRange(kernelMaximum, 1, deviceMaximum - 1);

        // (b) At the kernel maximum the block passes the kernel check; the budget one byte under one block's scratch is the only failure.
        long blockBytes;
        using (var probe = new MathBlocksCUDAWorker().CompileWithOptions(
            program, new MathBlocksCudaOptions { BlockSize = kernelMaximum, WindowScratchBudgetBytes = int.MaxValue }, inputs))
            blockBytes = probe.Launches.Max(launch => launch.ScratchBytesPerBlock);
        Assert.True(blockBytes >= 2, "One block of the window form has scratch.");
        var second = Assert.Throws<ArgumentOutOfRangeException>(() => new MathBlocksCUDAWorker().CompileWithOptions(
            program, new MathBlocksCudaOptions { BlockSize = kernelMaximum, WindowScratchBudgetBytes = blockBytes - 1 }, inputs));
        Assert.Equal(nameof(MathBlocksCudaOptions.WindowScratchBudgetBytes), second.ParamName);
        Assert.Contains($"MathBlocksCudaOptions.{nameof(MathBlocksCudaOptions.WindowScratchBudgetBytes)} is", second.Message, StringComparison.Ordinal);
    }

    // The single-operation program whose inputs are the prototype's values, in order.
    private static MathBlockProgram BuildSingleOperationProgram(MathBlockRegistry registry, MathBlockOperation operation, MathBlockValue[] prototype)
    {
        var builder = new MathBlockProgramBuilder(registry);
        var nodes = prototype.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        return builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
    }

    private static int DeviceMaximumThreadsPerBlock()
    {
        var native = typeof(MathBlocksCUDAWorker).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!;
        var limits = native.GetMethod("GetDeviceLimits")!.Invoke(null, [0])!;
        return (int)limits.GetType().GetProperty("MaximumThreadsPerBlock")!.GetValue(limits)!;
    }
}
