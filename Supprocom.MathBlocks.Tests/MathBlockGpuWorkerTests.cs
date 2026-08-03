using System.Diagnostics;
using System.Runtime.CompilerServices;
using Supprocom.MathBlocks.Gpu;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockGpuWorkerTests
{
    [Fact]
    public void GPU_catalog_contains_each_scalar_vector_boolean_and_complex_block()
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
                operation.Identifier is "transform.discrete-fourier" or
                    "transform.inverse-discrete-fourier" ||
                operation.Identifier == "special.error-function")
            .Select(operation => operation.Identity)
            .OrderBy(identity => identity, StringComparer.Ordinal)
            .ToArray();

        var supported = MathBlocksGPUWorker.SupportedBlockIdentities.ToHashSet(StringComparer.Ordinal);
        Assert.All(expected, identity => Assert.Contains(identity, supported));
        var registered = MathBlockCatalog.Standard.Operations
            .Select(operation => operation.Identity)
            .ToHashSet(StringComparer.Ordinal);
        Assert.All(supported, identity => Assert.Contains(identity, registered));
    }

    [Fact]
    public void GPU_formula_replays_one_resident_graph_with_parallel_branches()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var program = CreateParallelFormula();
        using var compiled = new MathBlocksGPUWorker().Compile(program);
        compiled.UploadInputs(new Dictionary<string, MathBlockValue>
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

        var gpu = compiled.ReadOutputs()["result"];
        var cpu = program.Evaluate(new Dictionary<string, MathBlockValue>
        {
            ["first"] = MathBlockValue.Scalar(6d),
            ["second"] = MathBlockValue.Scalar(2d),
            ["third"] = MathBlockValue.Scalar(1d),
            ["fourth"] = MathBlockValue.Scalar(4d)
        })["result"];

        AssertExact(cpu, gpu);
    }

    [Fact]
    public void GPU_program_queues_resident_replays_before_one_synchronization()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        using var compiled = new MathBlocksGPUWorker().Compile(CreateParallelFormula());
        compiled.UploadInputs(new Dictionary<string, MathBlockValue>
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

    [Fact]
    public void GPU_worker_exposes_only_one_graph_upload_and_one_graph_download_path()
    {
        var root = FindRepositoryRoot();
        var nativeSource = File.ReadAllText(Path.Combine(
            root,
            "Supprocom.MathBlocks",
            "Gpu",
            "Cuda",
            "MathBlocksCudaNative.cs"));
        var workerSource = File.ReadAllText(Path.Combine(
            root,
            "Supprocom.MathBlocks",
            "Execution",
            "MathBlocksGPUWorker.cs"));

        Assert.DoesNotContain("cuMemcpyHostToDevice", nativeSource, StringComparison.Ordinal);
        Assert.DoesNotContain("cuMemcpyDeviceToHost", nativeSource, StringComparison.Ordinal);
        Assert.Equal(
            2,
            workerSource.Split(
                "MathBlocksCudaNative.cuGraphAddMemcpyNode(",
                StringSplitOptions.None).Length - 1);
    }

    [Fact]
    public void GPU_kernel_ABI_uses_resident_input_pointer_arrays()
    {
        var root = FindRepositoryRoot();
        var workerSource = File.ReadAllText(Path.Combine(
            root,
            "Supprocom.MathBlocks",
            "Execution",
            "MathBlocksGPUWorker.cs"));
        foreach (var family in new[]
                 {
                     "Scalar", "Vector", "Complex", "Matrix", "Probability", "SequencePath", "Statistics",
                     "Geometry", "Graph", "Advanced", "Transport"
                 })
        {
            var source = File.ReadAllText(Path.Combine(
                root,
                "Supprocom.MathBlocks",
                "Gpu",
                "Blocks",
                family,
                $"{family}GpuBlockCatalog.cs"));
            Assert.Contains("const MathBlockSlot* const* inputs", source, StringComparison.Ordinal);
        }

        Assert.DoesNotContain("Inputs.Count >", workerSource, StringComparison.Ordinal);
        Assert.Contains("WriteInputPointers(", workerSource, StringComparison.Ordinal);
    }

    [Fact]
    public void GPU_arena_round_trips_every_value_kind_with_one_upload_and_one_download()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
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
        using var compiled = new MathBlocksGPUWorker().Compile(program, values);
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

    [Fact]
    public void GPU_scalar_reduction_scratch_remains_outside_the_download_region()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var values = MathBlockValue.Vector([4d, 1d, 3d, 2d]);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var input = builder.Input("values", values.Type);
        var median = builder.Apply("vector.median", inputs: [input]);
        var program = builder.Output("median", median).Build();
        using var compiled = new MathBlocksGPUWorker().Compile(
            program,
            new Dictionary<string, MathBlockValue> { ["values"] = values });
        compiled.UploadInputs(new Dictionary<string, MathBlockValue> { ["values"] = values });

        compiled.ExecuteResident();
        var output = compiled.ReadOutputs()["median"];

        AssertExact(MathBlockValue.Scalar(2.5d), output);
        Assert.Equal(48, compiled.DeviceToHostBytesPerExecution);
        Assert.Equal(1, compiled.HostToDeviceTransferCount);
        Assert.Equal(1, compiled.DeviceToHostTransferCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    [Fact]
    public void GPU_program_is_safe_for_concurrent_atomic_executions()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var program = new MathBlockFormulaBuilder(MathBlockCatalog.Standard)
            .Input("left", MathBlockType.Scalar())
            .Input("right", MathBlockType.Scalar())
            .Block("sum", "scalar.add", inputs: ["left", "right"])
            .Output("result", "sum")
            .Build();
        using var compiled = new MathBlocksGPUWorker().Compile(program);
        var results = new double[128];

        Parallel.For(0, results.Length, index =>
        {
            var outputs = compiled.Execute(new Dictionary<string, MathBlockValue>
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

    [Fact]
    public void Every_supported_GPU_block_matches_its_CPU_regression_output_exactly()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var failures = new List<string>();
        var parityCaseCount = 0;
        var worker = new MathBlocksGPUWorker();
        foreach (var identity in MathBlocksGPUWorker.SupportedBlockIdentities)
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
                var gpu = compiled.ReadOutputs()["result"];
                var cpu = operation.Evaluate(regression.Inputs);
                if (!IsExact(cpu, gpu))
                    failures.Add($"{identity}/{regression.Name}: CPU={Describe(cpu)}, GPU={Describe(gpu)}");
            }
        }

        Assert.True(parityCaseCount >= 300, $"Only {parityCaseCount} parity cases ran.");
        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    [Fact]
    [Trait("Category", "Performance")]
    public void Every_GPU_block_has_sub_millisecond_warm_latency_on_its_contract_shape()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        const int batchCount = 21;
        const int iterations = 16;
        var failures = new List<string>();
        var worker = new MathBlocksGPUWorker();
        foreach (var identity in MathBlocksGPUWorker.SupportedBlockIdentities)
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
                    $"{identity}: GPU warm median {warmMedian:F3} microseconds exceeds " +
                    $"{operation.PerformanceCase.MaximumWarmLatencyMicroseconds:F3} microseconds.");
            }
        }

        Assert.Empty(failures);
    }

    [Fact]
    [Trait("Category", "Performance")]
    public void Resident_GPU_formula_has_sub_millisecond_warm_latency()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        using var compiled = new MathBlocksGPUWorker().Compile(CreateParallelFormula());
        compiled.UploadInputs(new Dictionary<string, MathBlockValue>
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

        Assert.True(warmP99 < 1_000d, $"GPU warm p99 was {warmP99:F3} microseconds.");
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
            operation.Identifier != "special.error-function")
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
        if (operation.Identifier == "scalar.select")
        {
            yield return Case("select-false", [MathBlockValue.Boolean(false), Scalar(1, 1.25d), Scalar(2, -2.5d)]);
            yield return Case("select-true", [MathBlockValue.Boolean(true), Scalar(1, -0.75d), Scalar(2, 2.5d)]);
            yield break;
        }
        if (operation.Identifier == "scalar.clamp")
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
        Assert.True(IsExact(expected, actual), $"CPU={Describe(expected)}, GPU={Describe(actual)}");

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

    private static bool ExactBooleans(IReadOnlyList<bool> expected, IReadOnlyList<bool> actual) =>
        expected.Count == actual.Count && Enumerable.Range(0, expected.Count).All(index =>
            expected[index] == actual[index]);

    private static bool ExactComplex(Complex expected, Complex actual) =>
        ExactDouble(expected.Real, actual.Real) && ExactDouble(expected.Imaginary, actual.Imaginary);

    private static bool ExactComplexes(IReadOnlyList<Complex> expected, IReadOnlyList<Complex> actual) =>
        expected.Count == actual.Count && Enumerable.Range(0, expected.Count).All(index =>
            ExactComplex(expected[index], actual[index]));

    private static bool ExactPoints(IReadOnlyList<MathBlockPoint> expected, IReadOnlyList<MathBlockPoint> actual) =>
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

    private static bool ExactRuns(IReadOnlyList<MathBlockRun> expected, IReadOnlyList<MathBlockRun> actual) =>
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
            MathBlockValueKind.Vector => $"[{string.Join(",", value.AsVector().Select(item =>
                $"{item:R}/0x{BitConverter.DoubleToInt64Bits(item):x16}"))}]",
            MathBlockValueKind.BooleanVector => $"[{string.Join(",", value.AsBooleanVector())}]",
            _ => value.Type.ToString()
        };
    }

    private static string FindRepositoryRoot([CallerFilePath] string sourceFile = "")
    {
        var directory = new DirectoryInfo(Path.GetDirectoryName(sourceFile)!);
        while (directory is not null)
        {
            if (Directory.Exists(Path.Combine(directory.FullName, ".git")))
                return directory.FullName;
            directory = directory.Parent;
        }
        throw new DirectoryNotFoundException("The repository root was not found.");
    }
}
