using System.Diagnostics;
using System.Reflection;
using System.Runtime.CompilerServices;
using Supprocom.MathBlocks.Cuda;
using Xunit.Abstractions;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Cuda Worker Tests.</summary>
public sealed class MathBlockCudaWorkerTests(ITestOutputHelper testOutput)
{
    /// <summary>Verifies the NVRTC P/Invoke path compiles UTF-8 options without a CUDA device.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void NVRTCInteropCompilesWithoutADevice()
    {
        var nativeType = typeof(MathBlocksCUDAWorker).Assembly.GetType(
            "Supprocom.MathBlocks.Cuda.MathBlocksCudaNative",
            throwOnError: true);
        Assert.NotNull(nativeType);
        var compile = nativeType.GetMethod("CompilePtxForArchitecture", BindingFlags.NonPublic | BindingFlags.Static);
        Assert.NotNull(compile);

        var ptx = Assert.IsType<byte[]>(compile.Invoke(
            null,
            ["extern \"C\" __global__ void mathblocks_interop() {}", "mathblocks-interop.cu", "compute_86"]));
        Assert.NotEmpty(ptx);
    }

    /// <summary>
    /// Verifies the installed NVRTC reports a supported version and the file it was loaded from, and, when
    /// MATHBLOCKS_EXPECTED_NVRTC_VERSION is set, that it is that major.minor version.
    /// </summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void NVRTCLibraryReportsItsVersionAndFile()
    {
        var library = MathBlockCudaNvrtcLibrary.Current;
        testOutput.WriteLine(library.ToString());
        var expected = Environment.GetEnvironmentVariable("MATHBLOCKS_EXPECTED_NVRTC_VERSION");
        if (!string.IsNullOrEmpty(expected))
            Assert.Equal(expected, $"{library.Major}.{library.Minor}");

        Assert.True(library.Major >= 12, library.ToString());
        Assert.True(Path.IsPathFullyQualified(library.Path), library.ToString());
        Assert.True(File.Exists(library.Path), library.ToString());
        Assert.StartsWith(
            OperatingSystem.IsWindows() ? "nvrtc64_" : "libnvrtc",
            Path.GetFileName(library.Path),
            StringComparison.Ordinal);
        Assert.Same(library, MathBlockCudaNvrtcLibrary.Current);
    }

    /// <summary>Verifies cudacatalog contains each scalar vector boolean and complex block.</summary>
    [Fact]
    [Trait("Category", "CudaSourceContract")]
    public void CUDACatalogContainsEachScalarVectorBooleanAndComplexBlock()
    {
        var expected = MathBlockCatalog.Standard.Operations
            .Where(operation =>
                operation.Identifier.StartsWith("scalar.", StringComparison.Ordinal) ||
                operation.Identifier.StartsWith("boolean.", StringComparison.Ordinal) ||
                operation.Identifier.StartsWith("vector.", StringComparison.Ordinal) ||
                operation.Identifier.StartsWith("boolean-vector.", StringComparison.Ordinal) ||
                operation.Identifier.StartsWith("complex.", StringComparison.Ordinal) ||
                operation.Identifier.StartsWith("complex-vector.", StringComparison.Ordinal) ||
                operation.Identifier.StartsWith("complex-matrix.", StringComparison.Ordinal) ||
                (string.Equals(operation.Identifier, "transform.discrete-fourier", StringComparison.Ordinal) || string.Equals(operation.Identifier, "transform.inverse-discrete-fourier", StringComparison.Ordinal)) ||
string.Equals(operation.Identifier, "special.error-function", StringComparison.Ordinal))
            .Select(operation => operation.Identity)
            .Order(StringComparer.Ordinal)
            .ToArray();

        var supported = MathBlocksCUDAWorker.SupportedBlockIdentities.ToHashSet(StringComparer.Ordinal);
        Assert.All(expected, identity => Assert.Contains(identity, supported));
        var registered = MathBlockCatalog.Standard.Operations
            .Select(operation => operation.Identity)
            .ToHashSet(StringComparer.Ordinal);
        Assert.All(supported, identity => Assert.Contains(identity, registered));
    }

    /// <summary>Verifies cudaformula replays one resident graph with parallel branches.</summary>
    [Fact]
    public void CUDAFormulaReplaysOneResidentGraphWithParallelBranches()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var program = CreateParallelFormula();
        using var compiled = new MathBlocksCUDAWorker().Compile(program);
        compiled.UploadInputs(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["first"] = MathBlockValue.Scalar(6d),
            ["second"] = MathBlockValue.Scalar(2d),
            ["third"] = MathBlockValue.Scalar(1d),
            ["fourth"] = MathBlockValue.Scalar(4d)
        });

        compiled.ExecuteResident();

        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal(0, compiled.HostOutputReadCount);
        Assert.Equal(1, compiled.GraphInstantiationCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.HostToDeviceTransferCount);
        Assert.Equal(1, compiled.DeviceToHostTransferCount);
        Assert.Equal(48, compiled.DeviceToHostBytesPerExecution);
        Assert.True(compiled.HostToDeviceBytesPerExecution > compiled.DeviceToHostBytesPerExecution);
        Assert.Equal(3, compiled.OperationNodeCount);
        Assert.Equal(2, compiled.MaximumParallelWidth);

        var cuda = compiled.ReadOutputs()["result"];
        var cpu = program.Evaluate(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["first"] = MathBlockValue.Scalar(6d),
            ["second"] = MathBlockValue.Scalar(2d),
            ["third"] = MathBlockValue.Scalar(1d),
            ["fourth"] = MathBlockValue.Scalar(4d)
        })["result"];

        AssertExact(cpu, cuda);
    }

    /// <summary>Verifies cudaprogram queues resident replays before one synchronization.</summary>
    [Fact]
    public void CUDAProgramQueuesResidentReplaysBeforeOneSynchronization()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        using var compiled = new MathBlocksCUDAWorker().Compile(CreateParallelFormula());
        compiled.UploadInputs(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["first"] = MathBlockValue.Scalar(6d),
            ["second"] = MathBlockValue.Scalar(2d),
            ["third"] = MathBlockValue.Scalar(1d),
            ["fourth"] = MathBlockValue.Scalar(4d)
        });

        compiled.ExecuteResident();
        compiled.ExecuteResident();
        compiled.Synchronize();

        Assert.Equal(2, compiled.GraphLaunchCount);
        Assert.Equal(2, compiled.HostToDeviceTransferCount);
        Assert.Equal(2, compiled.DeviceToHostTransferCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        AssertExact(MathBlockValue.Scalar(8d), compiled.ReadOutputs()["result"]);
    }

    /// <summary>Verifies cudaworker exposes only one graph upload and one graph download path.</summary>
    [Fact]
    [Trait("Category", "CudaSourceContract")]
    public void CUDAWorkerExposesOnlyOneGraphUploadAndOneGraphDownloadPath()
    {
        var root = FindRepositoryRoot();
        var nativeSource = File.ReadAllText(Path.Combine(
            root,
            "Supprocom.MathBlocks",
            "Cuda",
            "Native",
            "MathBlocksCudaNative.cs"));
        var workerSource = File.ReadAllText(Path.Combine(
            root,
            "Supprocom.MathBlocks",
            "Execution",
            "MathBlocksCUDAProgram.cs"));

        Assert.DoesNotContain("cuMemcpyHostToDevice", nativeSource, StringComparison.Ordinal);
        Assert.DoesNotContain("cuMemcpyDeviceToHost", nativeSource, StringComparison.Ordinal);
        Assert.Equal(
            2,
            workerSource.Split(
                "MathBlocksCudaNative.cuGraphAddMemcpyNode(",
                StringSplitOptions.None).Length - 1);
    }

    /// <summary>Verifies cudakernel abipreserves readonly inputs across the dispatch bridge.</summary>
    [Fact]
    [Trait("Category", "CudaSourceContract")]
    public void CUDAKernelABIPreservesReadonlyInputsAcrossTheDispatchBridge()
    {
        var root = FindRepositoryRoot();
        var workerSource = File.ReadAllText(Path.Combine(
            root,
            "Supprocom.MathBlocks",
            "Execution",
            "MathBlocksCUDAProgram.cs"));
        var dispatchSource = File.ReadAllText(Path.Combine(
            root,
            "MathBlocks.CudaSourceGenerator",
            "TranslationUnits",
            "DeviceDispatchModule.cs"));
        foreach (var family in new[]
                 {
                     "Scalar", "Vector", "Complex", "Matrix", "Probability", "SequencePath", "Statistics",
                     "Geometry", "Graph", "Advanced", "Transport"
                 })
        {
            var source = File.ReadAllText(Path.Combine(
                root,
                    "MathBlocks.CudaSourceGenerator",
                "TranslationUnits",
                $"{family}Module.cs"));
            // CSharp2CUDA 0.3.1 needs mutable pointer-array temporaries here, but
            // every input slot remains read-only after the dispatcher boundary.
            Assert.Contains("MathBlockSlot** inputs", source, StringComparison.Ordinal);
            Assert.DoesNotContain("[CudaReadOnly] MathBlockSlot** inputs", source, StringComparison.Ordinal);
            Assert.Contains(
                "MathBlockSlot* first = Cuda.ReadOnly(input_count > 0 ? inputs[0] : null);",
                source,
                StringComparison.Ordinal);
        }

        Assert.Contains("[CudaReadOnly] MathBlockSlot** inputs", dispatchSource, StringComparison.Ordinal);
        Assert.Contains("mathblocks_dispatch_inputs(", dispatchSource, StringComparison.Ordinal);
        Assert.Contains(
            "const MathBlockSlot* const* inputs",
            MathBlockCudaDeviceModule.Source,
            StringComparison.Ordinal);
        Assert.DoesNotContain("Inputs.Count >", workerSource, StringComparison.Ordinal);
        Assert.Contains("WriteInputPointers(", workerSource, StringComparison.Ordinal);
    }

    /// <summary>Verifies cudaarena round trips every value kind with one upload and one download.</summary>
    [Fact]
    public void CUDAArenaRoundTripsEveryValueKindWithOneUploadAndOneDownload()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var unit = MathBlockUnit.Basis0;
        var values = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["scalar"] = MathBlockValue.Scalar(-0d, unit),
            ["boolean"] = MathBlockValue.Boolean(true),
            ["complex"] = MathBlockValue.Complex(new Complex(-0d, 2.75d), unit),
            ["vector"] = MathBlockValue.Vector([1.25d, -0d, -7.5d], unit),
            ["matrix"] = MathBlockValue.Matrix(
                new MathBlockMatrix(2, 2, [1.5d, -2.25d, -0d, 8d]),
                unit),
            ["complex-vector"] = MathBlockValue.ComplexVector(
                [new Complex(1.25d, -2.5d), new Complex(-0d, 7.75d)],
                unit),
            ["complex-matrix"] = MathBlockValue.ComplexMatrix(
                new MathBlockComplexMatrix(
                    2,
                    2,
                    [
                        new Complex(1d, 2d),
                        new Complex(-3d, 4d),
                        new Complex(-0d, -5d),
                        new Complex(6d, -7d)
                    ]),
                unit),
            ["point-set"] = MathBlockValue.PointSet(
                new MathBlockPointSet([
                    new MathBlockPoint(-0d, 2.5d),
                    new MathBlockPoint(-4.25d, 8.5d)
                ]),
                unit),
            ["graph"] = MathBlockValue.Graph(
                new MathBlockGraph(5, [
                    new MathBlockGraphEdge(0, 4, -0d),
                    new MathBlockGraphEdge(3, 1, 9.25d)
                ]),
                unit),
            ["run-set"] = MathBlockValue.RunSet(
                new MathBlockRunSet([
                    new MathBlockRun(0, 3, -0d),
                    new MathBlockRun(3, 7, 4.5d)
                ]),
                unit),
            ["boolean-vector"] = MathBlockValue.BooleanVector([true, false, true, true])
        };
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        foreach (var item in values)
        {
            var input = builder.Input(item.Key, item.Value.Type);
            builder.Output(item.Key, input);
        }
        var program = builder.Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(program, values);
        compiled.UploadInputs(values);

        compiled.ExecuteResident();
        var outputs = compiled.ReadOutputs();

        Assert.Equal(0, compiled.OperationNodeCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.HostToDeviceTransferCount);
        Assert.Equal(1, compiled.DeviceToHostTransferCount);
        Assert.Equal(values.Count, compiled.HostInputWriteCount);
        Assert.Equal(values.Count, compiled.HostOutputReadCount);
        foreach (var item in values)
            AssertExact(item.Value, outputs[item.Key]);
    }

    /// <summary>Verifies cudascalar reduction scratch remains outside the download region.</summary>
    [Fact]
    public void CUDAScalarReductionScratchRemainsOutsideTheDownloadRegion()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var values = MathBlockValue.Vector([4d, 1d, 3d, 2d]);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var input = builder.Input("values", values.Type);
        var median = builder.Apply("vector.median", inputs: [input]);
        var program = builder.Output("median", median).Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(
            program,
            new Dictionary<string, MathBlockValue>(StringComparer.Ordinal) { ["values"] = values });
        compiled.UploadInputs(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal) { ["values"] = values });

        compiled.ExecuteResident();
        var output = compiled.ReadOutputs()["median"];

        AssertExact(MathBlockValue.Scalar(2.5d), output);
        Assert.Equal(48, compiled.DeviceToHostBytesPerExecution);
        Assert.Equal(1, compiled.HostToDeviceTransferCount);
        Assert.Equal(1, compiled.DeviceToHostTransferCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    /// <summary>Verifies cudaconditional mutual information scratch preserves the following output slot.</summary>
    [Fact]
    public void CUDAConditionalMutualInformationScratchPreservesTheFollowingOutputSlot()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["guard"] = MathBlockValue.Scalar(123_456.75d),
            ["joint"] = MathBlockValue.Vector([0.5d, 0d, 0d, 0.5d]),
            ["first-count"] = MathBlockValue.Scalar(2d),
            ["second-count"] = MathBlockValue.Scalar(2d),
            ["condition-count"] = MathBlockValue.Scalar(1d)
        };
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var guard = builder.Input("guard", inputs["guard"].Type);
        var joint = builder.Input("joint", inputs["joint"].Type);
        var firstCount = builder.Input("first-count", inputs["first-count"].Type);
        var secondCount = builder.Input("second-count", inputs["second-count"].Type);
        var conditionCount = builder.Input("condition-count", inputs["condition-count"].Type);
        var information = builder.Apply(
            "information.conditional-mutual-information",
            inputs: [joint, firstCount, secondCount, conditionCount]);
        var program = builder
            .Output("guard", guard)
            .Output("information", information)
            .Build();
        var cpu = program.Evaluate(inputs);
        using var compiled = new MathBlocksCUDAWorker().Compile(program, inputs);
        compiled.UploadInputs(inputs);

        compiled.ExecuteResident();
        var cuda = compiled.ReadOutputs();

        Assert.True(cpu["information"].AsScalar() > 0d);
        AssertExact(cpu["guard"], cuda["guard"]);
        AssertExact(cpu["information"], cuda["information"]);
        AssertResidentExecutionContract(compiled);
    }

    /// <summary>Verifies cudadynamic repeat capacity propagates through boolean nodes.</summary>
    [Fact]
    public void CUDADynamicRepeatCapacityPropagatesThroughBooleanNodes()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["value"] = MathBlockValue.Scalar(2d),
            ["count"] = MathBlockValue.Scalar(4d)
        };
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var value = builder.Input("value", inputs["value"].Type);
        var count = builder.Input("count", inputs["count"].Type);
        var repeated = builder.Apply("vector.repeat", inputs: [value, count]);
        var equal = builder.Apply("vector.equal", inputs: [repeated, repeated]);
        var inverted = builder.Apply("boolean-vector.not", inputs: [equal]);
        var mask = builder.Apply("boolean-vector.and", inputs: [equal, inverted]);
        var trueCount = builder.Apply("boolean-vector.true-count", inputs: [mask]);
        var program = builder
            .Output("equal", equal)
            .Output("mask", mask)
            .Output("true-count", trueCount)
            .Build();
        var cpu = program.Evaluate(inputs);
        using var compiled = new MathBlocksCUDAWorker().Compile(program, inputs);
        compiled.UploadInputs(inputs);

        compiled.ExecuteResident();
        var cuda = compiled.ReadOutputs();

        AssertExact(MathBlockValue.BooleanVector([true, true, true, true]), cpu["equal"]);
        AssertExact(MathBlockValue.BooleanVector([false, false, false, false]), cpu["mask"]);
        AssertExact(MathBlockValue.Scalar(0d), cpu["true-count"]);
        Assert.All(cpu.Values, output => Assert.True(output.IsValid));
        Assert.All(cuda.Values, output => Assert.True(output.IsValid));
        AssertExact(cpu["equal"], cuda["equal"]);
        AssertExact(cpu["mask"], cuda["mask"]);
        AssertExact(cpu["true-count"], cuda["true-count"]);
        AssertResidentExecutionContract(compiled);
    }

    /// <summary>Verifies cudadynamic slice capacity propagates through concatenate and reduction.</summary>
    [Fact]
    public void CUDADynamicSliceCapacityPropagatesThroughConcatenateAndReduction()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["values"] = MathBlockValue.Vector([1d, 2d, 3d, 4d, 5d, 6d]),
            ["start"] = MathBlockValue.Scalar(1d),
            ["length"] = MathBlockValue.Scalar(3d),
            ["tail-value"] = MathBlockValue.Scalar(7d),
            ["tail-count"] = MathBlockValue.Scalar(1d),
            ["offset"] = MathBlockValue.Scalar(10d),
            ["threshold"] = MathBlockValue.Vector([11d, 13d, 13d, 20d])
        };
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var values = builder.Input("values", inputs["values"].Type);
        var start = builder.Input("start", inputs["start"].Type);
        var length = builder.Input("length", inputs["length"].Type);
        var tailValue = builder.Input("tail-value", inputs["tail-value"].Type);
        var tailCount = builder.Input("tail-count", inputs["tail-count"].Type);
        var offset = builder.Input("offset", inputs["offset"].Type);
        var threshold = builder.Input("threshold", inputs["threshold"].Type);
        var sliced = builder.Apply("vector.slice", inputs: [values, start, length]);
        var tail = builder.Apply("vector.repeat", inputs: [tailValue, tailCount]);
        var concatenated = builder.Apply("vector.concatenate", inputs: [sliced, tail]);
        var arithmetic = builder.Apply("vector.add-scalar", inputs: [concatenated, offset]);
        var comparison = builder.Apply("vector.greater-than", inputs: [arithmetic, threshold]);
        var indices = builder.Apply("boolean-vector.true-indices", inputs: [comparison]);
        var gathered = builder.Apply("vector.gather", inputs: [arithmetic, indices]);
        var sum = builder.Apply("vector.sum", inputs: [gathered]);
        var program = builder
            .Output("sliced", sliced)
            .Output("tail", tail)
            .Output("concatenated", concatenated)
            .Output("arithmetic", arithmetic)
            .Output("comparison", comparison)
            .Output("indices", indices)
            .Output("gathered", gathered)
            .Output("sum", sum)
            .Build();
        var cpu = program.Evaluate(inputs);
        using var compiled = new MathBlocksCUDAWorker().Compile(program, inputs);
        compiled.UploadInputs(inputs);

        compiled.ExecuteResident();
        var cuda = compiled.ReadOutputs();

        AssertExact(MathBlockValue.Vector([2d, 3d, 4d]), cpu["sliced"]);
        AssertExact(MathBlockValue.Vector([7d]), cpu["tail"]);
        AssertExact(MathBlockValue.Vector([2d, 3d, 4d, 7d]), cpu["concatenated"]);
        AssertExact(MathBlockValue.Vector([12d, 13d, 14d, 17d]), cpu["arithmetic"]);
        AssertExact(MathBlockValue.BooleanVector([true, false, true, false]), cpu["comparison"]);
        AssertExact(MathBlockValue.Vector([0d, 2d]), cpu["indices"]);
        AssertExact(MathBlockValue.Vector([12d, 14d]), cpu["gathered"]);
        AssertExact(MathBlockValue.Scalar(26d), cpu["sum"]);
        Assert.All(cpu.Values, output => Assert.True(output.IsValid));
        Assert.All(cuda.Values, output => Assert.True(output.IsValid));
        foreach (var output in cpu)
            AssertExact(output.Value, cuda[output.Key]);
        AssertResidentExecutionContract(compiled);
    }

    /// <summary>Verifies cudarolling order statistics preserve signed zero bits.</summary>
    [Fact]
    public void CUDARollingOrderStatisticsPreserveSignedZeroBits()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var negativeZero = BitConverter.Int64BitsToDouble(long.MinValue);
        Verify(
            [negativeZero, negativeZero, negativeZero, negativeZero, negativeZero],
            5,
            [negativeZero],
            [negativeZero],
            [negativeZero]);
        Verify(
            [negativeZero, 0d, 0d, negativeZero, 0d],
            3,
            [negativeZero, 0d, 0d],
            [0d, 0d, negativeZero],
            [negativeZero, 0d, 0d]);

        void Verify(
            IReadOnlyList<double> source,
            int widthValue,
            IReadOnlyList<double> expectedMinimum,
            IReadOnlyList<double> expectedMedian,
            IReadOnlyList<double> expectedMaximum)
        {
            var values = MathBlockValue.Vector(source);
            var width = MathBlockValue.Scalar(widthValue);
            var zero = MathBlockValue.Scalar(0d);
            var half = MathBlockValue.Scalar(0.5d);
            var one = MathBlockValue.Scalar(1d);
            var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["values"] = values,
                ["width"] = width,
                ["zero"] = zero,
                ["half"] = half,
                ["one"] = one
            };
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var valueNode = builder.Input("values", values.Type);
            var widthNode = builder.Input("width", width.Type);
            var zeroNode = builder.Input("zero", zero.Type);
            var halfNode = builder.Input("half", half.Type);
            var oneNode = builder.Input("one", one.Type);
            var minimum = builder.Apply(
                "sequence.rolling-quantile",
                inputs: [valueNode, widthNode, zeroNode]);
            var median = builder.Apply(
                "sequence.rolling-quantile",
                inputs: [valueNode, widthNode, halfNode]);
            var maximum = builder.Apply(
                "sequence.rolling-quantile",
                inputs: [valueNode, widthNode, oneNode]);
            var program = builder
                .Output("minimum", minimum)
                .Output("median", median)
                .Output("maximum", maximum)
                .Build();
            var cpu = program.Evaluate(inputs);
            AssertExact(MathBlockValue.Vector(expectedMinimum), cpu["minimum"]);
            AssertExact(MathBlockValue.Vector(expectedMedian), cpu["median"]);
            AssertExact(MathBlockValue.Vector(expectedMaximum), cpu["maximum"]);
            using var compiled = new MathBlocksCUDAWorker().Compile(program, inputs);
            compiled.UploadInputs(inputs);
            compiled.ExecuteResident();
            var cuda = compiled.ReadOutputs();
            AssertExact(cpu["minimum"], cuda["minimum"]);
            AssertExact(cpu["median"], cuda["median"]);
            AssertExact(cpu["maximum"], cuda["maximum"]);
            AssertResidentExecutionContract(compiled);
        }
    }

    /// <summary>Verifies cudarolling order statistics are exact and scale subquadratically.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void CUDARollingOrderStatisticsAreExactAndScaleSubquadratically()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var measurements = new List<double>();
        foreach (var count in new[] { 2_048, 4_096, 8_192 })
        {
            var values = MathBlockValue.Vector(
                Enumerable.Range(0, count).Select(index =>
                    (double)((index * 104_729 + 17) % 65_521)));
            var width = MathBlockValue.Scalar(count);
            var probability = MathBlockValue.Scalar(0.375d);
            var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["values"] = values,
                ["width"] = width,
                ["probability"] = probability
            };
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var valueNode = builder.Input("values", values.Type);
            var widthNode = builder.Input("width", width.Type);
            var probabilityNode = builder.Input("probability", probability.Type);
            var median = builder.Apply(
                "sequence.rolling-median",
                inputs: [valueNode, widthNode]);
            var quantile = builder.Apply(
                "sequence.rolling-quantile",
                inputs: [valueNode, widthNode, probabilityNode]);
            var program = builder
                .Output("median", median)
                .Output("quantile", quantile)
                .Build();
            var cpu = program.Evaluate(inputs);
            using var compiled = new MathBlocksCUDAWorker().Compile(program, inputs);
            compiled.UploadInputs(inputs);
            for (var warmup = 0; warmup < 3; warmup++)
            {
                compiled.ExecuteResident();
                compiled.Synchronize();
            }
            var samples = new double[7];
            for (var sample = 0; sample < samples.Length; sample++)
            {
                var started = Stopwatch.GetTimestamp();
                compiled.ExecuteResident();
                compiled.Synchronize();
                samples[sample] = Stopwatch.GetElapsedTime(started).TotalMicroseconds;
            }
            Array.Sort(samples);
            measurements.Add(samples[samples.Length / 2]);
            var cuda = compiled.ReadOutputs();
            AssertExact(cpu["median"], cuda["median"]);
            AssertExact(cpu["quantile"], cuda["quantile"]);
            Assert.Single(cuda["median"].AsVector());
            Assert.Single(cuda["quantile"].AsVector());
            Assert.Equal(0, compiled.CpuNodeDispatchCount);
        }

        Assert.True(
            measurements[1] < measurements[0] * 3.5d,
            $"The 2x rolling-size latency ratio was {measurements[1] / measurements[0]:F3}.");
        Assert.True(
            measurements[2] < measurements[1] * 3.5d,
            $"The 2x rolling-size latency ratio was {measurements[2] / measurements[1]:F3}.");
        Console.WriteLine(
            $"Rolling CUDA median latency: 2048={measurements[0]:F3} us, " +
            $"4096={measurements[1]:F3} us, 8192={measurements[2]:F3} us.");
    }

    /// <summary>Verifies cudafull history order statistics are exact and finish under one second.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void CUDAFullHistoryOrderStatisticsAreExactAndFinishUnderOneSecond()
    {
        const int count = 305_581;
        var values = MathBlockValue.Vector(
            Enumerable.Range(0, count).Select(index =>
                (double)((index * 104_729L + 17) % 1_000_003)));
        var width = MathBlockValue.Scalar(count);
        var worker = new MathBlocksCUDAWorker();
        var median = Measure("sequence.rolling-median", null);
        var quantile = Measure("sequence.rolling-quantile", 0.375d);
        var work = worker.PlanRollingOrderStatisticWork(count, count, 0.375d);
        Assert.True(work.UsesParallelRadixPreparation);
        Assert.False(work.UsesLinearExtremeDeque);
        Assert.Equal(64, work.RadixPassCount);
        Assert.Equal((long)count * 64, work.ParallelKeyVisitCount);
        Assert.Equal(0, work.HeapOperationBound);
        Assert.Equal(2, work.SelectionOperationBound);
        Assert.True(median.WorstMilliseconds < 1_000d, $"Median worst time was {median.WorstMilliseconds:F3} ms.");
        Assert.True(quantile.WorstMilliseconds < 1_000d, $"Quantile worst time was {quantile.WorstMilliseconds:F3} ms.");
        Console.WriteLine(
            $"Full-history CUDA order statistics at {count} values: " +
            $"median median={median.MedianMilliseconds:F3} ms worst={median.WorstMilliseconds:F3} ms; " +
            $"quantile median={quantile.MedianMilliseconds:F3} ms worst={quantile.WorstMilliseconds:F3} ms; " +
            $"radix-passes={work.RadixPassCount}; key-visits={work.ParallelKeyVisitCount}.");

        (double MedianMilliseconds, double WorstMilliseconds) Measure(
            string identity,
            double? probability)
        {
            var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["values"] = values,
                ["width"] = width
            };
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var valueNode = builder.Input("values", values.Type);
            var widthNode = builder.Input("width", width.Type);
            int output;
            if (probability.HasValue)
            {
                var probabilityValue = MathBlockValue.Scalar(probability.Value);
                inputs.Add("probability", probabilityValue);
                var probabilityNode = builder.Input("probability", probabilityValue.Type);
                output = builder.Apply(identity, inputs: [valueNode, widthNode, probabilityNode]);
            }
            else
            {
                output = builder.Apply(identity, inputs: [valueNode, widthNode]);
            }
            var program = builder.Output("result", output).Build();
            var cpu = program.Evaluate(inputs)["result"];
            using var compiled = worker.Compile(program, inputs);
            compiled.UploadInputs(inputs);
            for (var warmup = 0; warmup < 3; warmup++)
            {
                compiled.ExecuteResident();
                compiled.Synchronize();
            }
            var samples = new double[5];
            for (var sample = 0; sample < samples.Length; sample++)
            {
                var started = Stopwatch.GetTimestamp();
                compiled.ExecuteResident();
                compiled.Synchronize();
                samples[sample] = Stopwatch.GetElapsedTime(started).TotalMilliseconds;
            }
            var cuda = compiled.ReadOutputs()["result"];
            AssertExact(cpu, cuda);
            Assert.Single(cuda.AsVector());
            Array.Sort(samples);
            return (samples[samples.Length / 2], samples[^1]);
        }
    }

    /// <summary>Verifies cudarolling order statistics cover full scale windows and adversarial inputs.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void CUDARollingOrderStatisticsCoverFullScaleWindowsAndAdversarialInputs()
    {
        const int count = 305_581;
        var widths = new[] { 1, 100, 2_048, count / 2, count };
        var worker = new MathBlocksCUDAWorker();
        foreach (var pattern in new[] { "ordered", "reverse", "equal", "alternating", "pseudorandom" })
        {
            var raw = new double[count];
            for (var index = 0; index < raw.Length; index++)
            {
                raw[index] = pattern switch
                {
                    "ordered" => index - count / 2d,
                    "reverse" => count / 2d - index,
                    "equal" => 17d,
                    "alternating" => (index & 1) == 0 ? -1e100 : 1e100,
                    _ => (index * 104_729L + 17) % 1_000_003 - 500_001d
                };
            }
            var values = MathBlockValue.Vector(raw);
            foreach (var widthValue in widths)
            {
                var width = MathBlockValue.Scalar(widthValue);
                var zero = MathBlockValue.Scalar(0d);
                var half = MathBlockValue.Scalar(0.5d);
                var one = MathBlockValue.Scalar(1d);
                var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
                {
                    ["values"] = values,
                    ["width"] = width,
                    ["zero"] = zero,
                    ["half"] = half,
                    ["one"] = one
                };
                var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
                var valuesNode = builder.Input("values", values.Type);
                var widthNode = builder.Input("width", width.Type);
                var zeroNode = builder.Input("zero", zero.Type);
                var halfNode = builder.Input("half", half.Type);
                var oneNode = builder.Input("one", one.Type);
                var median = builder.Apply(
                    "sequence.rolling-median",
                    inputs: [valuesNode, widthNode]);
                var minimum = builder.Apply(
                    "sequence.rolling-quantile",
                    inputs: [valuesNode, widthNode, zeroNode]);
                var quantile = builder.Apply(
                    "sequence.rolling-quantile",
                    inputs: [valuesNode, widthNode, halfNode]);
                var maximum = builder.Apply(
                    "sequence.rolling-quantile",
                    inputs: [valuesNode, widthNode, oneNode]);
                var program = builder
                    .Output("median", median)
                    .Output("minimum", minimum)
                    .Output("quantile", quantile)
                    .Output("maximum", maximum)
                    .Build();
                var cpu = program.Evaluate(inputs);
                using var compiled = worker.Compile(program, inputs);
                var cuda = compiled.Execute(inputs);
                AssertExact(cpu["median"], cuda["median"]);
                AssertExact(cpu["minimum"], cuda["minimum"]);
                AssertExact(cpu["quantile"], cuda["quantile"]);
                AssertExact(cpu["maximum"], cuda["maximum"]);
                AssertExact(cpu["median"], cpu["quantile"]);

                var minimumWork = worker.PlanRollingOrderStatisticWork(count, widthValue, 0d);
                var medianWork = worker.PlanRollingOrderStatisticWork(count, widthValue, 0.5d);
                var maximumWork = worker.PlanRollingOrderStatisticWork(count, widthValue, 1d);
                Assert.Equal(0, minimumWork.RadixPassCount);
                Assert.Equal(0, maximumWork.RadixPassCount);
                Assert.True(widthValue == 1 || minimumWork.UsesLinearExtremeDeque);
                Assert.True(widthValue == 1 || maximumWork.UsesLinearExtremeDeque);
                Assert.True(
                    medianWork.TotalOperationBound < (long)count * count,
                    $"The fixed work bound is not subquadratic for width {widthValue}.");
                Assert.Equal(1, compiled.HostToDeviceTransferCount);
                Assert.Equal(1, compiled.GraphLaunchCount);
                Assert.Equal(1, compiled.SynchronizationCount);
                Assert.Equal(1, compiled.DeviceToHostTransferCount);
                Assert.Equal(0, compiled.CpuNodeDispatchCount);
            }
        }
    }

    /// <summary>Verifies cudaprogram is safe for concurrent atomic executions.</summary>
    [Fact]
    public void CUDAProgramIsSafeForConcurrentAtomicExecutions()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var program = new MathBlockFormulaBuilder(MathBlockCatalog.Standard)
            .Input("left", MathBlockType.Scalar())
            .Input("right", MathBlockType.Scalar())
            .Block("sum", "scalar.add", inputs: ["left", "right"])
            .Output("result", "sum")
            .Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(program);
        var results = new double[128];

        Parallel.For(0, results.Length, index =>
        {
            var outputs = compiled.Execute(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["left"] = MathBlockValue.Scalar(index + 0.25d),
                ["right"] = MathBlockValue.Scalar(index * 2d + 0.5d)
            });
            results[index] = outputs["result"].AsScalar();
        });

        for (var index = 0; index < results.Length; index++)
            Assert.Equal(index * 3d + 0.75d, results[index]);
        Assert.Equal(results.Length, compiled.GraphLaunchCount);
        Assert.Equal(results.Length, compiled.HostToDeviceTransferCount);
        Assert.Equal(results.Length, compiled.DeviceToHostTransferCount);
    }

    /// <summary>Verifies every supported cudablock matches its cpuregression output exactly.</summary>
    [Fact]
    public void EverySupportedCUDABlockMatchesItsCPURegressionOutputExactly()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var failures = new List<string>();
        var parityCaseCount = 0;
        var worker = new MathBlocksCUDAWorker();
        foreach (var identity in MathBlocksCUDAWorker.SupportedBlockIdentities)
        {
            var separator = identity.LastIndexOf('@');
            var operation = MathBlockCatalog.Standard.Get(
                identity[..separator],
                int.Parse(identity[(separator + 1)..], System.Globalization.CultureInfo.InvariantCulture));
            var cases = CreateParityCases(operation).ToArray();
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var inputNodes = cases[0].Inputs
                .Select((input, index) => builder.Input($"input-{index}", input.Type))
                .ToArray();
            var outputNode = builder.Apply(operation.Identifier, operation.Version, inputNodes);
            var program = builder.Output("result", outputNode).Build();
            var prototypeInputs = cases[0].Inputs
                .Select((input, index) => new KeyValuePair<string, MathBlockValue>($"input-{index}", input))
                .ToDictionary(item => item.Key, item => item.Value, StringComparer.Ordinal);
            using var compiled = worker.Compile(program, prototypeInputs);
            foreach (var regression in cases)
            {
                parityCaseCount++;
                compiled.UploadInputs(regression.Inputs
                    .Select((input, index) => new KeyValuePair<string, MathBlockValue>($"input-{index}", input))
                    .ToDictionary(item => item.Key, item => item.Value, StringComparer.Ordinal));
                compiled.ExecuteResident();
                var cuda = compiled.ReadOutputs()["result"];
                var cpu = operation.Evaluate(regression.Inputs);
                if (!IsExact(cpu, cuda))
                    failures.Add($"{identity}/{regression.Name}: CPU={Describe(cpu)}, CUDA={Describe(cuda)}");
            }
        }

        Assert.True(parityCaseCount >= 300, $"Only {parityCaseCount} parity cases ran.");
        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>
    /// Verifies the inverse sine and cosine give the CoreCLR bits on CUDA across [-1, 1]: a dense dyadic grid,
    /// fixed pseudo-random points, the 512 doubles next to each of -1 and 1, every power of two down to the
    /// smallest subnormal, and both zeros.
    /// </summary>
    [Theory]
    [InlineData("scalar.arc-sine")]
    [InlineData("scalar.arc-cosine")]
    public void CUDAInverseSineAndCosineMatchCoreCLRBitForBitAcrossTheDomain(string identifier)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var unit = operation.RegressionCases[0].Inputs[0].Type.Unit;
        var values = CreateUnitIntervalInputs();
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var input = builder.Input("input-0", MathBlockValue.Scalar(0d, unit).Type);
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, input)).Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(
            program,
            new Dictionary<string, MathBlockValue>(StringComparer.Ordinal) { ["input-0"] = MathBlockValue.Scalar(0d, unit) });
        var failures = new List<string>();
        foreach (var value in values)
        {
            MathBlockValue[] inputs = [MathBlockValue.Scalar(value, unit)];
            compiled.UploadInputs(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal) { ["input-0"] = inputs[0] });
            compiled.ExecuteResident();
            var cuda = compiled.ReadOutputs()["result"];
            var coreclr = operation.Evaluate(inputs);
            if (!IsExact(coreclr, cuda))
            {
                failures.Add(string.Create(
                    System.Globalization.CultureInfo.InvariantCulture,
                    $"x={value:R} (0x{BitConverter.DoubleToInt64Bits(value):X16}): CoreCLR={Describe(coreclr)}, CUDA={Describe(cuda)}"));
            }
        }

        Assert.True(values.Length > 20_000, $"Only {values.Length} inputs were generated.");
        Assert.True(
            failures.Count == 0,
            $"{identifier}: {failures.Count} of {values.Length} inputs differ. First 20:{Environment.NewLine}" +
            string.Join(Environment.NewLine, failures.Take(20)));
    }

    /// <summary>
    /// Gets every scalar and special operation with scalar inputs, plus the elementwise and reduction vector forms
    /// whose result can carry the sign of a zero input.
    /// </summary>
    public static TheoryData<string> SignedZeroParityOperations
    {
        get
        {
            var data = new TheoryData<string>();
            foreach (var operation in MathBlockCatalog.Standard.Operations)
            {
                if ((operation.Identifier.StartsWith("scalar.", StringComparison.Ordinal) ||
                     operation.Identifier.StartsWith("special.", StringComparison.Ordinal)) &&
                    operation.RegressionCases[0].Inputs.All(input => input.Type.Kind == MathBlockValueKind.Scalar))
                {
                    data.Add(operation.Identifier);
                }
            }
            foreach (var identifier in SignedZeroVectorOperations)
                data.Add(identifier);
            foreach (var identifier in SignedZeroComplexOperations)
                data.Add(identifier);
            return data;
        }
    }

    private static readonly string[] SignedZeroVectorOperations =
    [
        "vector.absolute", "vector.sign", "vector.positive-part", "vector.square", "vector.square-root",
        "vector.exponential", "vector.cumulative-sum", "vector.cumulative-product", "vector.sum", "vector.product",
        "vector.maximum", "vector.minimum", "vector.add", "vector.subtract", "vector.multiply", "vector.divide",
        "vector.scale", "vector.add-scalar", "vector.power"
    ];

    // The C99 Annex G branch-cut operations, which take the sign of a zero imaginary part from arc-tangent-2.
    private static readonly string[] SignedZeroComplexOperations =
    [
        "complex.phase", "complex.natural-logarithm", "complex.square-root"
    ];

    /// <summary>
    /// Verifies CUDA gives the CoreCLR bits for every combination of +0, -0, 1, -1 and 0.5 in the scalar inputs, with
    /// vector inputs that hold every pairing of signed zeros.
    /// </summary>
    [Theory]
    [MemberData(nameof(SignedZeroParityOperations))]
    public void CUDASignedZeroMatchesCoreCLRBitForBit(string identifier)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var operation = MathBlockCatalog.Standard.Get(identifier);
        var cases = CreateSignedZeroCases(operation);
        // Compile from a case with a finite CoreCLR result: MathBlocksCUDAProgram constant-folds the prototype.
        var prototype = Array.Find(
            cases,
            inputs => !IsRejectedClampCase(operation, inputs) && operation.Evaluate(inputs).IsValid);
        Assert.True(
            prototype is not null && operation.Evaluate(prototype).IsValid,
            $"{identifier}: no case has a finite CoreCLR result to compile from.");
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var inputNodes = prototype.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, inputNodes)).Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(program, Named(prototype));
        var failures = new List<string>();
        var skipped = 0;
        foreach (var inputs in cases)
        {
            if (IsRejectedClampCase(operation, inputs))
            {
                skipped++;
                continue;
            }
            var coreclr = operation.Evaluate(inputs);
            compiled.UploadInputs(Named(inputs));
            compiled.ExecuteResident();
            var cuda = compiled.ReadOutputs()["result"];
            if (!IsExact(coreclr, cuda))
                failures.Add($"({string.Join(", ", inputs.Select(DescribeBits))}): CoreCLR={DescribeBits(coreclr)}, CUDA={DescribeBits(cuda)}");
        }

        Assert.True(
            failures.Count == 0,
            $"{identifier}: {failures.Count} of {cases.Length - skipped} cases differ ({skipped} clamp cases with lower > upper skipped): " +
            string.Join("; ", failures));

        static Dictionary<string, MathBlockValue> Named(MathBlockValue[] inputs) =>
            inputs.Select((input, index) => (Name: $"input-{index}", Input: input))
                .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
    }

    // CoreCLR clamp throws ArgumentException when lower > upper, so those cases have no result to match. This skip
    // goes once M4-CUDA makes clamp return an invalid value on both sides. Any other exception fails the test.
    private static bool IsRejectedClampCase(MathBlockOperation operation, MathBlockValue[] inputs) =>
        string.Equals(operation.Identifier, "scalar.clamp", StringComparison.Ordinal) &&
        inputs[1].AsScalar() > inputs[2].AsScalar();

    private static string DescribeBits(MathBlockValue value)
    {
        if (!value.IsValid)
            return "invalid";
        static string Bits(double number) => $"0x{BitConverter.DoubleToInt64Bits(number):X16}";
        return value.Type.Kind switch
        {
            MathBlockValueKind.Scalar => Bits(value.AsScalar()),
            MathBlockValueKind.Complex => $"({Bits(value.AsComplex().Real)}, {Bits(value.AsComplex().Imaginary)}i)",
            MathBlockValueKind.Vector => $"[{string.Join(' ', value.AsVector().ToArray().Select(Bits))}]",
            _ => Describe(value)
        };
    }

    private static MathBlockValue[][] CreateSignedZeroCases(MathBlockOperation operation)
    {
        // 0.5 gives operations such as logit a finite case to compile from.
        double[] scalars = [0d, -0d, 1d, -1d, 0.5d];
        // The first vector has no negative nonzero, so square-root stays finite; divide gets nonzero divisors.
        double[][] vectors =
        [
            [0d, 0d, -0d, -0d, 1d, 2d, 0d, -0d],
            string.Equals(operation.Identifier, "vector.divide", StringComparison.Ordinal)
                ? [1d, -1d, 1d, -1d, 2d, -2d, 0.5d, -0.5d]
                : [0d, -0d, 0d, -0d, 0d, 0d, 1d, -1d]
        ];
        var reference = operation.RegressionCases[0].Inputs;
        var cases = new List<MathBlockValue[]>();
        var combinations = 1;
        for (var index = 0; index < reference.Count; index++)
        {
            if (reference[index].Type.Kind == MathBlockValueKind.Scalar)
                combinations *= scalars.Length;
            else if (reference[index].Type.Kind == MathBlockValueKind.Complex)
                combinations *= scalars.Length * scalars.Length;
        }
        for (var combination = 0; combination < combinations; combination++)
        {
            var inputs = new MathBlockValue[reference.Count];
            var remaining = combination;
            var vectorIndex = 0;
            for (var index = 0; index < reference.Count; index++)
            {
                var unit = reference[index].Type.Unit;
                if (reference[index].Type.Kind == MathBlockValueKind.Scalar)
                {
                    inputs[index] = MathBlockValue.Scalar(scalars[remaining % scalars.Length], unit);
                    remaining /= scalars.Length;
                }
                else if (reference[index].Type.Kind == MathBlockValueKind.Complex)
                {
                    var real = scalars[remaining % scalars.Length];
                    remaining /= scalars.Length;
                    inputs[index] = MathBlockValue.Complex(new Complex(real, scalars[remaining % scalars.Length]), unit);
                    remaining /= scalars.Length;
                }
                else
                {
                    inputs[index] = MathBlockValue.Vector(vectors[vectorIndex++ % vectors.Length], unit);
                }
            }
            cases.Add(inputs);
        }
        return [.. cases];
    }

    private static double[] CreateUnitIntervalInputs()
    {
        var values = new List<double> { 0d, -0d, 1d, -1d };
        for (var index = 0; index <= 16_384; index++)
            values.Add(-1d + (index / 8_192d));
        // SplitMix64 with a fixed seed, mapped to [-1, 1).
        var state = 0x9E37_79B9_7F4A_7C15ul;
        for (var index = 0; index < 4_096; index++)
        {
            state += 0x9E37_79B9_7F4A_7C15ul;
            var bits = state;
            bits = (bits ^ (bits >> 30)) * 0xBF58_476D_1CE4_E5B9ul;
            bits = (bits ^ (bits >> 27)) * 0x94D0_49BB_1331_11EBul;
            bits ^= bits >> 31;
            values.Add(((bits >> 11) * (1d / (1ul << 53)) * 2d) - 1d);
        }
        var nearOne = 1d;
        for (var step = 0; step < 512; step++)
        {
            nearOne = Math.BitDecrement(nearOne);
            values.Add(nearOne);
            values.Add(-nearOne);
        }
        for (var exponent = 1; exponent <= 1_074; exponent++)
        {
            var power = Math.ScaleB(1d, -exponent);
            values.Add(power);
            values.Add(-power);
            values.Add(1d - power);
            values.Add(power - 1d);
        }
        values.Add(double.Epsilon * 3d);
        values.Add(-double.Epsilon * 3d);
        values.Add(BitConverter.Int64BitsToDouble(0x000F_FFFF_FFFF_FFFFL));
        values.Add(-BitConverter.Int64BitsToDouble(0x000F_FFFF_FFFF_FFFFL));
        return [.. values];
    }

    /// <summary>Verifies every cudablock has sub millisecond warm latency on its contract shape.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void EveryCUDABlockHasSubMillisecondWarmLatencyOnItsContractShape()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        const int batchCount = 21;
        const int iterations = 16;
        var failures = new List<string>();
        var worker = new MathBlocksCUDAWorker();
        foreach (var identity in MathBlocksCUDAWorker.SupportedBlockIdentities)
        {
            var separator = identity.LastIndexOf('@');
            var operation = MathBlockCatalog.Standard.Get(
                identity[..separator],
                int.Parse(identity[(separator + 1)..], System.Globalization.CultureInfo.InvariantCulture));
            var inputs = operation.PerformanceCase.Inputs;
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var inputNodes = inputs
                .Select((input, index) => builder.Input($"input-{index}", input.Type))
                .ToArray();
            var outputNode = builder.Apply(operation.Identifier, operation.Version, inputNodes);
            var program = builder.Output("result", outputNode).Build();
            var inputValues = inputs
                .Select((input, index) => new KeyValuePair<string, MathBlockValue>($"input-{index}", input))
                .ToDictionary(item => item.Key, item => item.Value, StringComparer.Ordinal);
            using var compiled = worker.Compile(program, inputValues);
            compiled.UploadInputs(inputValues);
            for (var warmup = 0; warmup < 64; warmup++)
                compiled.ExecuteResident();
            compiled.Synchronize();

            var samples = new double[batchCount];
            for (var batch = 0; batch < batchCount; batch++)
            {
                var started = Stopwatch.GetTimestamp();
                for (var iteration = 0; iteration < iterations; iteration++)
                    compiled.ExecuteResident();
                compiled.Synchronize();
                samples[batch] = Stopwatch.GetElapsedTime(started).TotalMilliseconds * 1_000d / iterations;
            }
            Array.Sort(samples);
            var warmMedian = samples[10];
            if (warmMedian >= operation.PerformanceCase.MaximumWarmLatencyMicroseconds)
            {
                failures.Add(
                    $"{identity}: CUDA warm median {warmMedian:F3} microseconds exceeds " +
                    $"{operation.PerformanceCase.MaximumWarmLatencyMicroseconds:F3} microseconds.");
            }
        }

        Assert.Empty(failures);
    }

    /// <summary>Verifies resident cudaformula has sub millisecond warm latency.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void ResidentCUDAFormulaHasSubMillisecondWarmLatency()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        using var compiled = new MathBlocksCUDAWorker().Compile(CreateParallelFormula());
        compiled.UploadInputs(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["first"] = MathBlockValue.Scalar(6d),
            ["second"] = MathBlockValue.Scalar(2d),
            ["third"] = MathBlockValue.Scalar(1d),
            ["fourth"] = MathBlockValue.Scalar(4d)
        });
        for (var warmup = 0; warmup < 64; warmup++)
        {
            compiled.ExecuteResident();
            compiled.Synchronize();
        }

        const int batchCount = 101;
        const int iterations = 64;
        var samples = new double[batchCount];
        for (var batch = 0; batch < batchCount; batch++)
        {
            var started = Stopwatch.GetTimestamp();
            for (var iteration = 0; iteration < iterations; iteration++)
            {
                compiled.ExecuteResident();
                compiled.Synchronize();
            }
            samples[batch] = Stopwatch.GetElapsedTime(started).TotalMilliseconds * 1_000d / iterations;
        }
        Array.Sort(samples);
        var warmP99 = samples[(int)Math.Ceiling(batchCount * 0.99d) - 1];

        Assert.True(warmP99 < 1_000d, $"CUDA warm p99 was {warmP99:F3} microseconds.");
    }

    private static MathBlockProgram CreateParallelFormula() =>
        new MathBlockFormulaBuilder(MathBlockCatalog.Standard)
            .Block("quotient", "scalar.divide", inputs: ["left-side", "right-side"])
            .Block("right-side", "scalar.add", inputs: ["second", "third"])
            .Block("left-side", "scalar.multiply", inputs: ["first", "fourth"])
            .Input("fourth", MathBlockType.Scalar())
            .Input("third", MathBlockType.Scalar())
            .Input("second", MathBlockType.Scalar())
            .Input("first", MathBlockType.Scalar())
            .Output("result", "quotient")
            .Build();

    private static void AssertResidentExecutionContract(MathBlocksCUDAProgram compiled)
    {
        Assert.Equal(1, compiled.GraphInstantiationCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.HostToDeviceTransferCount);
        Assert.Equal(1, compiled.DeviceToHostTransferCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    private static IEnumerable<MathBlockRegressionCase> CreateParityCases(MathBlockOperation operation)
    {
        foreach (var regression in operation.RegressionCases)
            yield return regression;

        if (operation.Identifier.StartsWith("vector.", StringComparison.Ordinal) ||
            operation.Identifier.StartsWith("boolean-vector.", StringComparison.Ordinal))
        {
            yield break;
        }

        if (!operation.Identifier.StartsWith("scalar.", StringComparison.Ordinal) &&
            !operation.Identifier.StartsWith("boolean.", StringComparison.Ordinal) &&
!string.Equals(operation.Identifier, "special.error-function", StringComparison.Ordinal))
        {
            yield break;
        }

        var reference = operation.RegressionCases[0].Inputs;
        MathBlockValue Scalar(int index, double value) => MathBlockValue.Scalar(value, reference[index].Type.Unit);
        if (operation.Identifier.StartsWith("boolean.", StringComparison.Ordinal))
        {
            yield return Case("boolean-a", operation.Arity == 1
                ? [MathBlockValue.Boolean(false)]
                : [MathBlockValue.Boolean(false), MathBlockValue.Boolean(true)]);
            yield return Case("boolean-b", operation.Arity == 1
                ? [MathBlockValue.Boolean(true)]
                : [MathBlockValue.Boolean(true), MathBlockValue.Boolean(true)]);
            yield break;
        }
        if (string.Equals(operation.Identifier, "scalar.select", StringComparison.Ordinal))
        {
            yield return Case("select-false", [MathBlockValue.Boolean(false), Scalar(1, 1.25d), Scalar(2, -2.5d)]);
            yield return Case("select-true", [MathBlockValue.Boolean(true), Scalar(1, -0.75d), Scalar(2, 2.5d)]);
            yield break;
        }
        if (string.Equals(operation.Identifier, "scalar.clamp", StringComparison.Ordinal))
        {
            yield return Case("clamp-middle", [Scalar(0, 0.375d), Scalar(1, -1.25d), Scalar(2, 0.875d)]);
            yield return Case("clamp-low", [Scalar(0, -2.5d), Scalar(1, -1.25d), Scalar(2, 0.875d)]);
            yield return Case("clamp-high", [Scalar(0, 2.5d), Scalar(1, -1.25d), Scalar(2, 0.875d)]);
            yield break;
        }
        if (operation.Arity == 2)
        {
            var pairs = operation.Identifier switch
            {
                "scalar.power" => new[] { (1.25d, 2.5d), (2.5d, -0.75d), (0.375d, 1.25d) },
                "scalar.divide" or "scalar.modulo" =>
                    new[] { (0.375d, -1.25d), (-2.5d, 0.75d), (7.25d, 2.5d) },
                "scalar.arc-tangent-2" =>
                    new[] { (0.375d, -1.25d), (-2.5d, 0.75d), (-0.75d, -1.25d) },
                _ => new[] { (0.375d, -1.25d), (-2.5d, 0.75d), (1.25d, 1.25d) }
            };
            for (var index = 0; index < pairs.Length; index++)
                yield return Case($"binary-{index}", [Scalar(0, pairs[index].Item1), Scalar(1, pairs[index].Item2)]);
            yield break;
        }

        double[] values = operation.Identifier switch
        {
            "scalar.square-root" or "scalar.natural-logarithm" or "scalar.binary-logarithm" or
                "scalar.common-logarithm" => [0.125d, 0.5d, 1.25d, 2.5d],
            "scalar.arc-sine" or "scalar.arc-cosine" or "scalar.inverse-hyperbolic-tangent" or
                "scalar.logit" => [0.125d, 0.25d, 0.75d, 0.875d],
            "scalar.inverse-hyperbolic-cosine" => [1d, 1.25d, 2.5d, 8d],
            "scalar.log-one-plus" => [-0.75d, -0.125d, 0.125d, 1.25d],
            "scalar.reciprocal" => [-2.5d, -0.75d, 0.125d, 1.25d],
            _ => [-2.5d, -0.75d, -0.125d, 0d, 0.125d, 0.75d, 2.5d]
        };
        for (var index = 0; index < values.Length; index++)
            yield return Case($"unary-{index}", [Scalar(0, values[index])]);

        MathBlockRegressionCase Case(string name, IReadOnlyList<MathBlockValue> inputs) =>
            new(name, inputs, operation.Evaluate(inputs));
    }

    private static void AssertExact(MathBlockValue expected, MathBlockValue actual) =>
        Assert.True(IsExact(expected, actual), $"CPU={Describe(expected)}, CUDA={Describe(actual)}");

    private static bool IsExact(MathBlockValue expected, MathBlockValue actual)
    {
        if (expected.Type != actual.Type || expected.IsValid != actual.IsValid)
            return false;
        if (!expected.IsValid)
            return true;
        return expected.Type.Kind switch
        {
            MathBlockValueKind.Scalar =>
                BitConverter.DoubleToInt64Bits(expected.AsScalar()) ==
                BitConverter.DoubleToInt64Bits(actual.AsScalar()),
            MathBlockValueKind.Boolean => expected.AsBoolean() == actual.AsBoolean(),
            MathBlockValueKind.Complex => ExactComplex(expected.AsComplex(), actual.AsComplex()),
            MathBlockValueKind.Vector => ExactDoubles(expected.AsVector(), actual.AsVector()),
            MathBlockValueKind.Matrix => ExactDoubles(
                expected.AsMatrix().ToArray(),
                actual.AsMatrix().ToArray()) &&
                expected.AsMatrix().Rows == actual.AsMatrix().Rows &&
                expected.AsMatrix().Columns == actual.AsMatrix().Columns,
            MathBlockValueKind.ComplexVector => ExactComplexes(
                expected.AsComplexVector(),
                actual.AsComplexVector()),
            MathBlockValueKind.ComplexMatrix => ExactComplexes(
                expected.AsComplexMatrix().ToArray(),
                actual.AsComplexMatrix().ToArray()) &&
                expected.AsComplexMatrix().Rows == actual.AsComplexMatrix().Rows &&
                expected.AsComplexMatrix().Columns == actual.AsComplexMatrix().Columns,
            MathBlockValueKind.PointSet => ExactPoints(expected.AsPointSet(), actual.AsPointSet()),
            MathBlockValueKind.Graph => ExactGraphs(expected.AsGraph(), actual.AsGraph()),
            MathBlockValueKind.RunSet => ExactRuns(expected.AsRunSet(), actual.AsRunSet()),
            MathBlockValueKind.BooleanVector => ExactBooleans(
                expected.AsBooleanVector(),
                actual.AsBooleanVector()),
            _ => false
        };
    }

    private static bool ExactDoubles(IReadOnlyList<double> expected, IReadOnlyList<double> actual) =>
        expected.Count == actual.Count && Enumerable.Range(0, expected.Count).All(index =>
            BitConverter.DoubleToInt64Bits(expected[index]) == BitConverter.DoubleToInt64Bits(actual[index]));

    private static bool ExactBooleans(MathBlockBooleanVector expected, MathBlockBooleanVector actual) =>
        expected.Count == actual.Count && Enumerable.Range(0, expected.Count).All(index =>
            expected[index] == actual[index]);

    private static bool ExactComplex(Complex expected, Complex actual) =>
        ExactDouble(expected.Real, actual.Real) && ExactDouble(expected.Imaginary, actual.Imaginary);

    private static bool ExactComplexes(IReadOnlyList<Complex> expected, IReadOnlyList<Complex> actual) =>
        expected.Count == actual.Count && Enumerable.Range(0, expected.Count).All(index =>
            ExactComplex(expected[index], actual[index]));

    private static bool ExactPoints(MathBlockPointSet expected, MathBlockPointSet actual) =>
        expected.Count == actual.Count && Enumerable.Range(0, expected.Count).All(index =>
            ExactDouble(expected[index].X, actual[index].X) &&
            ExactDouble(expected[index].Y, actual[index].Y));

    private static bool ExactGraphs(MathBlockGraph expected, MathBlockGraph actual) =>
        expected.VertexCount == actual.VertexCount &&
        expected.Count == actual.Count &&
        Enumerable.Range(0, expected.Count).All(index =>
            expected[index].From == actual[index].From &&
            expected[index].To == actual[index].To &&
            ExactDouble(expected[index].Weight, actual[index].Weight));

    private static bool ExactRuns(MathBlockRunSet expected, MathBlockRunSet actual) =>
        expected.Count == actual.Count && Enumerable.Range(0, expected.Count).All(index =>
            expected[index].Start == actual[index].Start &&
            expected[index].Length == actual[index].Length &&
            ExactDouble(expected[index].Value, actual[index].Value));

    private static bool ExactDouble(double expected, double actual) =>
        BitConverter.DoubleToInt64Bits(expected) == BitConverter.DoubleToInt64Bits(actual);

    private static string Describe(MathBlockValue value)
    {
        if (!value.IsValid)
            return "invalid";
        return value.Type.Kind switch
        {
            MathBlockValueKind.Scalar =>
                $"{value.AsScalar():R}/0x{BitConverter.DoubleToInt64Bits(value.AsScalar()):x16}",
            MathBlockValueKind.Boolean => value.AsBoolean().ToString(),
            MathBlockValueKind.Vector => $"[{string.Join(',', value.AsVector().Select(item =>
                $"{item:R}/0x{BitConverter.DoubleToInt64Bits(item):x16}"))}]",
            MathBlockValueKind.BooleanVector => $"[{string.Join(',', value.AsBooleanVector())}]",
            _ => value.Type.ToString()
        };
    }

    private static string FindRepositoryRoot([CallerFilePath] string sourceFile = "")
    {
        var directory = new DirectoryInfo(Path.GetDirectoryName(sourceFile)!);
        while (directory is not null)
        {
            if (Path.Exists(Path.Combine(directory.FullName, ".git")))
                return directory.FullName;
            directory = directory.Parent;
        }
        throw new DirectoryNotFoundException("The repository root was not found.");
    }
}
