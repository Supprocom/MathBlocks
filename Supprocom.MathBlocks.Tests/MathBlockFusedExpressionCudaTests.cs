using System.Diagnostics;
using Supprocom.MathBlocks.Cuda;
using Xunit.Abstractions;
using static Supprocom.MathBlocks.Tests.MathBlockFusedTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks CoreCLR/CUDA parity of fused expressions on a CUDA device.</summary>
public sealed class MathBlockFusedExpressionCudaTests(ITestOutputHelper output)
{
    /// <summary>
    /// The fused CUDA kernel equals EvaluateCoreCLR bit for bit, including invalid state, reasons, row validity and
    /// the invalid mask, and equals the generic dispatcher's values and validity, under --fmad=false and --fmad=true.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaExecution")]
    [InlineData(false)]
    [InlineData(true)]
    public void CUDAFusedKernelEqualsCoreCLRAndTheGenericDispatcherBitForBit(bool fusedMultiplyAdd)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var cases = CreateCases();
        var (ran, valid, _) = AssertCudaCases(cases, fusedMultiplyAdd);
        output.WriteLine($"fmad={fusedMultiplyAdd}: {ran} cases, {valid} valid outputs compared bit for bit.");
    }

    /// <summary>
    /// Fused programs with elementwise forms and siblings: the CUDA kernel equals EvaluateCoreCLR bit for bit,
    /// including invalid state, reasons, row validity and the invalid mask, and equals the generic dispatcher's values
    /// and validity, under --fmad=false and --fmad=true. The cases are every form and sibling under every broadcast
    /// mask on edge rows, every source at the full row count, random programs and invalid inputs.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaExecution")]
    [InlineData(false)]
    [InlineData(true)]
    public void CUDAFusedElementwiseKernelEqualsCoreCLRAndTheGenericDispatcherBitForBit(bool fusedMultiplyAdd)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var cases = CreateElementwiseCases(out var expected);
        var (ran, valid, filled) = AssertCudaCases(cases, fusedMultiplyAdd);
        output.WriteLine($"fmad={fusedMultiplyAdd}: {ran} elementwise cases, {valid} valid outputs and {filled} " +
                         "filled rows of valid outputs compared bit for bit.");
        Assert.Equal(expected, ran);
        // Guards against cases that never reach the fill select: filled rows of valid outputs were compared.
        Assert.True(filled > 0, "No filled row of a valid output was compared.");
    }

    // Runs the cases in one NVRTC program and compares each with EvaluateCoreCLR and the generic dispatcher. Returns
    // the cases compared, the valid outputs and the rows of valid outputs that are not valid in their row validity.
    private (int Ran, int Valid, long Filled) AssertCudaCases(
        (string Name, MathBlockFusedExpression Expression, Dictionary<string, MathBlockValue> Inputs,
            Dictionary<string, MathBlockValue>? Validity)[] cases,
        bool fusedMultiplyAdd)
    {
        var expressions = cases.Select(item => item.Expression).ToArray();
        var distinct = expressions.DistinctBy(expression => expression.Fingerprint, StringComparer.Ordinal);
        var source = string.Concat(distinct.Select(expression => expression.CudaSource + "\n"));

        var watch = Stopwatch.StartNew();
        var results = RunCuda(
            source,
            fusedMultiplyAdd,
            expressions,
            cases.Select(item => (IReadOnlyDictionary<string, MathBlockValue>)item.Inputs).ToArray(),
            cases.Select(item => (IReadOnlyDictionary<string, MathBlockValue>?)item.Validity).ToArray());
        output.WriteLine($"fmad={fusedMultiplyAdd}: {cases.Length} cases compiled and run in {watch.Elapsed.TotalSeconds:F1} s.");

        var worker = new MathBlocksCUDAWorker();
        var valid = 0;
        var filled = 0L;
        var ran = 0;
        for (var index = 0; index < cases.Length; index++)
        {
            var (name, expression, inputs, validity) = cases[index];
            var context = $"{name} fmad={fusedMultiplyAdd}";
            var reference = expression.EvaluateCoreCLR(inputs, validity);
            Assert.Equal(reference.InvalidMask, results[index].InvalidMask);
            var caseValid = 0;
            foreach (var (outputName, value) in reference.Outputs)
            {
                AssertSameValue(value, results[index].Outputs[outputName], $"{context} output {outputName}");
                AssertSameValue(reference.Validity[outputName], results[index].Validity[outputName], $"{context} validity {outputName}");
                if (value.IsValid)
                {
                    caseValid++;
                    if (reference.Validity[outputName].IsValid)
                        filled += reference.Validity[outputName].AsBooleanVector().Count(flag => !flag);
                }
            }
            valid += caseValid;
            ran++;
            output.WriteLine($"{context}: {caseValid} of {reference.Outputs.Count} outputs valid");

            using var generic = worker.Compile(expression.Program, inputs);
            IReadOnlyDictionary<string, MathBlockValue> dispatched;
            try
            {
                dispatched = generic.Execute(inputs);
            }
            catch (ArgumentException exception) when (
                exception.Message.StartsWith("A valid vector must contain finite values.", StringComparison.Ordinal))
            {
                // The generic Complex dispatcher's magnitude case (opcode 16) has no finiteness check, so an
                // overflowing magnitude reaches the host as a valid slot with an infinite element, and reading it
                // throws. CoreCLR and the fused kernel mark that node invalid.
                Assert.Contains(
                    expression.Program.PlanNodes,
                    node => string.Equals(node.OperationIdentity, "complex-vector.magnitude@1", StringComparison.Ordinal));
                output.WriteLine($"{context}: the generic dispatcher returned a nonfinite magnitude.");
                continue;
            }
            foreach (var (outputName, value) in results[index].Outputs)
            {
                var other = dispatched[outputName];
                Assert.True(
                    value.IsValid == other.IsValid,
                    $"{context} output {outputName}: fused valid {value.IsValid}, generic dispatcher valid {other.IsValid}.");
                if (value.IsValid)
                    AssertSamePayload(other, value, $"{context} output {outputName} against the generic dispatcher");
            }
        }
        return (ran, valid, filled);
    }

    /// <summary>Times the fused kernel against the generic dispatcher at the full row count.</summary>
    /// <remarks>
    /// Both times have the inputs already on the device and exclude downloads: the fused time is one kernel launch
    /// and synchronization, and the generic time is one launch of the resident graph and its synchronization.
    /// </remarks>
    [Fact]
    [Trait("Category", "CudaExecution")]
    [Trait("Category", "Performance")]
    public void CUDAFusedKernelTimingAtFullRowCount()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var random = new Random(4);
        TimeAtFullRowCount(CreateRandomProgram(random, 4, 1, 1, 64, 4), random);
    }

    /// <summary>
    /// Times the fused kernel against the generic dispatcher at the full row count, for random programs of 64
    /// operation nodes of which about half are elementwise forms and siblings.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaExecution")]
    [Trait("Category", "Performance")]
    public void CUDAFusedElementwiseKernelTimingAtFullRowCount()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        foreach (var seed in new[] { 5, 6 })
        {
            var random = new Random(seed);
            TimeAtFullRowCount(CreateRandomProgram(random, 4, 1, 1, 64, 4, elementwisePercent: 50), random);
        }
    }

    // Both times have the inputs already on the device and exclude downloads: the fused time is one kernel launch
    // and synchronization, and the generic time is one launch of the resident graph and its synchronization.
    private void TimeAtFullRowCount(MathBlockProgram program, Random random)
    {
        const int repeats = 10;
        var expression = MathBlockFusedExpression.Create(program);
        var inputs = CreateInputs(program, FullRows, Regime.Benign, random);
        RunCuda(
            expression.CudaSource,
            false,
            Enumerable.Repeat(expression, repeats + 1).ToArray(),
            Enumerable.Repeat((IReadOnlyDictionary<string, MathBlockValue>)inputs, repeats + 1).ToArray(),
            Enumerable.Repeat((IReadOnlyDictionary<string, MathBlockValue>?)null, repeats + 1).ToArray());
        var runner = typeof(MathBlocksCUDAWorker).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlockFusedCudaRunner", true)!;
        var fused = ((IReadOnlyList<double>)runner.GetProperty("LaunchMilliseconds")!.GetValue(null)!).Skip(1).ToArray();

        using var generic = new MathBlocksCUDAWorker().Compile(program, inputs);
        generic.UploadInputs(inputs);
        generic.ExecuteResident();
        generic.Synchronize();
        var dispatched = new double[repeats];
        for (var repeat = 0; repeat < repeats; repeat++)
        {
            var watch = Stopwatch.StartNew();
            generic.ExecuteResident();
            generic.Synchronize();
            dispatched[repeat] = watch.Elapsed.TotalMilliseconds;
        }
        var ratios = fused.Zip(dispatched, (left, right) => left / right).ToArray();
        var elementwise = program.PlanNodes.Count(node =>
            node.OperationIdentity?.StartsWith("elementwise", StringComparison.Ordinal) == true);
        output.WriteLine($"{expression.MaskNodeIndexes.Count} operation nodes ({elementwise} elementwise), {FullRows} rows, {repeats} repeats");
        output.WriteLine($"fused kernel ms: {Spread(fused)}");
        output.WriteLine($"generic dispatcher graph ms: {Spread(dispatched)}");
        output.WriteLine($"fused / generic, per repeat: {Spread(ratios)}");
        output.WriteLine($"fused kernel ms, each: {string.Join(' ', fused.Select(value => value.ToString("F3", System.Globalization.CultureInfo.InvariantCulture)))}");
        output.WriteLine($"generic ms, each: {string.Join(' ', dispatched.Select(value => value.ToString("F3", System.Globalization.CultureInfo.InvariantCulture)))}");
    }

    private static string Spread(double[] values)
    {
        var sorted = values.Order().ToArray();
        var median = (sorted[(sorted.Length - 1) / 2] + sorted[sorted.Length / 2]) / 2d;
        return string.Create(
            System.Globalization.CultureInfo.InvariantCulture,
            $"min {sorted[0]:F4}, median {median:F4}, max {sorted[^1]:F4}");
    }

    private static (string Name, MathBlockFusedExpression Expression, Dictionary<string, MathBlockValue> Inputs,
        Dictionary<string, MathBlockValue>? Validity)[] CreateCases()
    {
        var cases = new List<(string, MathBlockFusedExpression, Dictionary<string, MathBlockValue>, Dictionary<string, MathBlockValue>?)>();
        var random = new Random(611);

        var golden = MathBlockFusedExpression.Create(MathBlockFusedExpressionSourceTests.CreateGoldenProgram());
        foreach (var regime in Enum.GetValues<Regime>())
        {
            var inputs = CreateInputs(golden.Program, FullRows, regime, random);
            cases.Add(($"golden {regime}", golden, inputs, CreateValidity(golden.Program, FullRows, random)));
        }

        // A multiply feeding an add is the pattern a contracting compiler turns into a fused multiply-add.
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector());
        var y = builder.Input("y", MathBlockType.Vector());
        var z = builder.Input("z", MathBlockType.Vector());
        var contracted = MathBlockFusedExpression.Create(builder
            .Output("a", builder.Apply("vector.add", 1, builder.Apply("vector.multiply", 1, x, y), z))
            .Output("b", builder.Apply("vector.subtract", 1, z, builder.Apply("vector.multiply", 1, y, y)))
            .Build());
        cases.Add(("multiply-add", contracted, CreateInputs(contracted.Program, FullRows, Regime.Signed, random), null));

        // One whole-vector invalid row makes an output invalid, so at the full row count most random programs end
        // invalid. For two thirds of the trials, the first of up to 40 drawn programs with a valid output is kept.
        for (var trial = 0; trial < 60; trial++)
        {
            var regime = (Regime)(trial % 3);
            var rows = trial < 12 ? FullRows : random.Next(1, 500);
            var preferValid = trial % 3 != 2;
            for (var attempt = 0; ; attempt++)
            {
                var program = CreateRandomProgram(
                    random, random.Next(1, 7), random.Next(0, 3), random.Next(0, 3),
                    random.Next(1, MathBlockFusedExpression.MaximumOperationNodes + 1),
                    random.Next(1, MathBlockFusedExpression.MaximumOutputs + 1));
                var fused = MathBlockFusedExpression.Create(program);
                var inputs = CreateInputs(program, rows, regime, random);
                var validity = CreateValidity(program, rows, random);
                if (preferValid && attempt < 40 &&
                    !fused.EvaluateCoreCLR(inputs, validity).Outputs.Values.Any(value => value.IsValid))
                    continue;
                cases.Add(($"random {trial} ({regime}, {rows} rows)", fused, inputs, validity));
                break;
            }
        }

        foreach (var (identity, arguments, _) in Operations)
            AddAdversarialCases(cases, identity, arguments);
        return [.. cases];
    }

    // Every form and sibling under every broadcast mask on the edge cases of the CoreCLR tests; every source with
    // every argument a vector at the full row count; random programs with elementwise forms, a fifth of them at the
    // full row count; and the invalid-state cases. expected is the number of cases the generators produce.
    private static (string Name, MathBlockFusedExpression Expression, Dictionary<string, MathBlockValue> Inputs,
        Dictionary<string, MathBlockValue>? Validity)[] CreateElementwiseCases(out int expected)
    {
        var cases = new List<(string, MathBlockFusedExpression, Dictionary<string, MathBlockValue>, Dictionary<string, MathBlockValue>?)>();
        expected = 0;
        foreach (var source in MathBlockElementwiseTestSupport.SourceIdentifiers)
        {
            foreach (var mask in MathBlockElementwiseTestSupport.BroadcastMasks(source))
            {
                MathBlockFusedExpression? fused = null;
                foreach (var (name, program, inputs, validity) in MathBlockFusedExpressionElementwiseTests.CreateEdgeCases(source, mask))
                {
                    fused ??= MathBlockFusedExpression.Create(program);
                    cases.Add((name, fused, inputs, validity));
                }
                expected += MathBlockFusedExpressionElementwiseTests.EdgeCasesPerMask;
            }

            var vectors = (1 << MathBlockElementwiseTestSupport.SourceArity(source)) - 1;
            var edge = MathBlockFusedExpressionElementwiseTests.CreateEdgeCases(source, vectors).First();
            var arguments = MathBlockElementwiseTestSupport.CreateArguments(source, FullRows, vectors, 61_000 + source.Length);
            var full = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["other"] = MathBlockValue.Vector(Enumerable.Range(0, FullRows).Select(row => row % 1_000 * 0.25d).ToArray()),
                ["fill"] = MathBlockValue.Scalar(-0d)
            };
            for (var index = 0; index < arguments.Length; index++)
                full[$"a{index}"] = arguments[index];
            var fullValidity = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["a0"] = MathBlockValue.BooleanVector(Enumerable.Range(0, FullRows).Select(row => row % 13 != 5))
            };
            cases.Add(($"{source} all vectors, {FullRows} rows", MathBlockFusedExpression.Create(edge.Program), full, fullValidity));
            expected++;
        }

        const int trials = 40;
        var random = new Random(612);
        for (var trial = 0; trial < trials; trial++)
        {
            var regime = (Regime)(trial % 3);
            var rows = trial < trials / 5 ? FullRows : random.Next(1, 500);
            var preferValid = trial % 3 != 2;
            for (var attempt = 0; ; attempt++)
            {
                var program = CreateRandomProgram(
                    random, random.Next(1, 7), random.Next(0, 3), random.Next(0, 3),
                    random.Next(1, MathBlockFusedExpression.MaximumOperationNodes + 1),
                    random.Next(1, MathBlockFusedExpression.MaximumOutputs + 1),
                    elementwisePercent: 40);
                var fused = MathBlockFusedExpression.Create(program);
                var inputs = CreateInputs(program, rows, regime, random);
                var validity = CreateValidity(program, rows, random);
                if (preferValid && attempt < 40 &&
                    !fused.EvaluateCoreCLR(inputs, validity).Outputs.Values.Any(value => value.IsValid))
                    continue;
                cases.Add(($"elementwise random {trial} ({regime}, {rows} rows)", fused, inputs, validity));
                break;
            }
        }
        expected += trials;

        var (_, invalidState) = MathBlockFusedExpressionElementwiseTests.CreateInvalidStateProgram();
        expected += MathBlockFusedExpressionElementwiseTests.CreateInvalidStateCases().Count();
        foreach (var (name, inputs) in MathBlockFusedExpressionElementwiseTests.CreateInvalidStateCases())
            cases.Add(($"invalid state {name}", invalidState, inputs, null));
        return [.. cases];
    }

    // Each operation on every pair of adversarial values, once as one vector (usually invalid as a whole) and once
    // restricted to the pairs whose single-row result is valid, so the valid bits are compared too.
    private static void AddAdversarialCases(
        List<(string, MathBlockFusedExpression, Dictionary<string, MathBlockValue>, Dictionary<string, MathBlockValue>?)> cases,
        string identity,
        string arguments)
    {
        var values = AdversarialValues;
        var pairs = new List<(double Left, double Right)>();
        foreach (var left in values)
            foreach (var right in values)
                pairs.Add((left, right));
        var scalars = arguments.Contains('S', StringComparison.Ordinal) ? new[] { 2d, -0d, 0.5, 1d / 3d, -1d } : [2d];
        foreach (var scalar in scalars)
        {
            var (program, all) = CreatePairProgram(identity, arguments, pairs, scalar);
            var fused = MathBlockFusedExpression.Create(program);
            cases.Add(($"{identity} all pairs, scalar {scalar:R}", fused, all, null));
            var kept = pairs.Where(pair =>
            {
                var (_, single) = CreatePairProgram(identity, arguments, [pair], scalar);
                return program.Evaluate(single).Values.All(value => value.IsValid);
            }).ToList();
            if (kept.Count > 0)
                cases.Add(($"{identity} valid pairs, scalar {scalar:R}", fused,
                    CreatePairProgram(identity, arguments, kept, scalar).Inputs, null));
        }
    }

    private static (MathBlockProgram Program, Dictionary<string, MathBlockValue> Inputs) CreatePairProgram(
        string identity,
        string arguments,
        List<(double Left, double Right)> pairs,
        double scalar)
    {
        var left = pairs.Select(pair => pair.Left).ToArray();
        var right = pairs.Select(pair => pair.Right).ToArray();
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal);
        var nodes = new List<int>();
        var numbers = 0;
        foreach (var kind in arguments)
        {
            switch (kind)
            {
                case 'N':
                    var name = $"x{numbers}";
                    nodes.Add(builder.Input(name, MathBlockType.Vector()));
                    inputs[name] = MathBlockValue.Vector(numbers++ % 2 == 0 ? left : right);
                    break;
                case 'S':
                    nodes.Add(builder.Input("s", MathBlockType.Scalar()));
                    inputs["s"] = MathBlockValue.Scalar(scalar);
                    break;
                case 'B':
                    var flag = $"b{nodes.Count}";
                    nodes.Add(builder.Input(flag, MathBlockType.BooleanVector()));
                    inputs[flag] = MathBlockValue.BooleanVector(
                        Enumerable.Range(0, pairs.Count).Select(row => (row + nodes.Count) % 3 == 0));
                    break;
                default:
                    nodes.Add(builder.Apply(
                        "complex-vector.create", 1,
                        builder.Input("re", MathBlockType.Vector()), builder.Input("im", MathBlockType.Vector())));
                    inputs["re"] = MathBlockValue.Vector(left);
                    inputs["im"] = MathBlockValue.Vector(right);
                    break;
            }
        }
        var result = builder.Apply(identity, 1, [.. nodes]);
        if (string.Equals(identity, "complex-vector.create", StringComparison.Ordinal))
        {
            builder.Output("imaginary", builder.Apply("complex-vector.imaginary", 1, result));
            result = builder.Apply("complex-vector.real", 1, result);
        }
        builder.Output("y", result);
        return (builder.Build(), inputs);
    }
}
