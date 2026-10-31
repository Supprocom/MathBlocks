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
                    caseValid++;
            }
            valid += caseValid;
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
        output.WriteLine($"fmad={fusedMultiplyAdd}: {cases.Length} cases, {valid} valid outputs compared bit for bit.");
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
        const int repeats = 10;
        var random = new Random(4);
        var program = CreateRandomProgram(random, 4, 1, 1, 64, 4);
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
        output.WriteLine($"{expression.MaskNodeIndexes.Count} operation nodes, {FullRows} rows, {repeats} repeats");
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
