using System.Security.Cryptography;
using System.Text;
using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockFusedTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks the fused expression's CoreCLR reference, its limits and its fingerprint.</summary>
public sealed class MathBlockFusedExpressionTests
{
    /// <summary>Random pointwise programs within the limits give the unfused program's outputs bit for bit.</summary>
    [Fact]
    public void CoreCLRRandomProgramsEqualTheUnfusedProgramBitForBit()
    {
        var random = new Random(20261031);
        for (var trial = 0; trial < 240; trial++)
        {
            var program = CreateRandomProgram(
                random,
                vectorInputs: random.Next(1, 7),
                booleanInputs: random.Next(0, 3),
                scalarInputs: random.Next(0, 3),
                operations: random.Next(1, MathBlockFusedExpression.MaximumOperationNodes + 1),
                outputs: random.Next(1, MathBlockFusedExpression.MaximumOutputs + 1));
            var fused = MathBlockFusedExpression.Create(program);
            var regime = (Regime)(trial % 3);
            var rows = trial % 7 == 0 ? random.Next(0, 3) : random.Next(1, 400);
            var inputs = CreateInputs(program, rows, regime, random);
            var validity = CreateValidity(program, rows, random);
            AssertMatchesUnfused(
                program,
                inputs,
                validity,
                fused.EvaluateCoreCLR(inputs, validity),
                $"trial {trial} ({regime}, {rows} rows)");
        }
    }

    /// <summary>Random programs give the unfused outputs at the full row count, 302,893.</summary>
    [Fact]
    public void CoreCLRRandomProgramsEqualTheUnfusedProgramAtFullRowCount()
    {
        var random = new Random(302893);
        for (var trial = 0; trial < 6; trial++)
        {
            var program = CreateRandomProgram(random, 4, 1, 1, trial == 0 ? 64 : random.Next(8, 40), 4);
            var fused = MathBlockFusedExpression.Create(program);
            var regime = (Regime)(trial % 3);
            var inputs = CreateInputs(program, FullRows, regime, random);
            var validity = CreateValidity(program, FullRows, random);
            AssertMatchesUnfused(
                program,
                inputs,
                validity,
                fused.EvaluateCoreCLR(inputs, validity),
                $"full trial {trial} ({regime})");
        }
    }

    /// <summary>Each supported operation alone gives the unfused bits on adversarial rows.</summary>
    [Fact]
    public void CoreCLREachOperationEqualsTheUnfusedOperationOnAdversarialRows()
    {
        var values = AdversarialValues;
        var rows = values.Length * values.Length;
        var left = new double[rows];
        var right = new double[rows];
        var flags = new bool[rows];
        for (var row = 0; row < rows; row++)
        {
            left[row] = values[row / values.Length];
            right[row] = values[row % values.Length];
            flags[row] = (row & 1) == 0;
        }

        foreach (var (identity, arguments, _) in Operations)
        {
            var scalars = arguments.Contains('S', StringComparison.Ordinal)
                ? new[] { 2d, -0d, 0.5, 1d / 3d, -1d, 1e-310, 1e300 }
                : [2d];
            foreach (var scalar in scalars)
            {
                // Each operation runs on every pair of adversarial values in one vector, so a single bad row makes
                // the whole result invalid. It also runs on the pairs one row at a time to compare the valid bits.
                foreach (var single in new[] { false, true })
                {
                    var count = single ? 1 : rows;
                    for (var start = 0; start < (single ? rows : 1); start++)
                    {
                        var (program, inputs) = CreateSingleOperation(
                            identity, arguments, left.AsSpan(start, count), right.AsSpan(start, count),
                            flags.AsSpan(start, count), scalar);
                        var fused = MathBlockFusedExpression.Create(program);
                        AssertMatchesUnfused(
                            program, inputs, None(),
                            fused.EvaluateCoreCLR(inputs), $"{identity} scalar {scalar:R} start {start}");
                    }
                }
            }
        }
    }

    /// <summary>A nonfinite row propagates its reason through later nodes, as in the unfused program.</summary>
    [Fact]
    public void CoreCLRInvalidStateAndReasonsFollowTheUnfusedProgram()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector());
        var y = builder.Input("y", MathBlockType.Vector());
        var p = builder.Input("p", MathBlockType.Scalar());
        var logarithm = builder.Apply("vector.natural-logarithm", 1, x);
        var sum = builder.Apply("vector.add", 1, logarithm, y);
        var scaled = builder.Apply("vector.power", 1, y, p);
        var less = builder.Apply("vector.less-than", 1, sum, scaled);
        var program = builder.Output("sum", sum).Output("scaled", scaled).Output("less", less)
            .Output("x", x).Build();
        var fused = MathBlockFusedExpression.Create(program);

        var cases = new[]
        {
            (MathBlockValue.Vector([1d, 2d, 0d]), MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Scalar(2d)),
            (MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Vector([0d, 2d, 3d]), MathBlockValue.Scalar(-1d)),
            (MathBlockValue.Invalid(MathBlockType.Vector(), "x is missing."), MathBlockValue.Vector([1d, 2d, 3d]),
                MathBlockValue.Scalar(2d)),
            (MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Vector([1d, 2d, 3d]),
                MathBlockValue.Invalid(MathBlockType.Scalar(), "p is missing.")),
            (MathBlockValue.Invalid(MathBlockType.Vector(), "x is missing."),
                MathBlockValue.Invalid(MathBlockType.Vector(), "y is missing."), MathBlockValue.Scalar(2d)),
            (MathBlockValue.Vector([1d, 0d, 3d]), MathBlockValue.Invalid(MathBlockType.Vector(), "y is missing."),
                MathBlockValue.Scalar(2d)),
            (MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Vector([1e300, 2d, 3d]), MathBlockValue.Scalar(2d))
        };
        foreach (var (first, second, exponent) in cases)
        {
            var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["x"] = first,
                ["y"] = second,
                ["p"] = exponent
            };
            var result = fused.EvaluateCoreCLR(inputs);
            AssertMatchesUnfused(program, inputs, None(), result, "invalid case");
        }
        var bothInvalid = fused.EvaluateCoreCLR(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Invalid(MathBlockType.Vector(), "x is missing."),
            ["y"] = MathBlockValue.Invalid(MathBlockType.Vector(), "y is missing."),
            ["p"] = MathBlockValue.Scalar(2d)
        });
        Assert.Equal("x is missing.", bothInvalid.Outputs["sum"].InvalidReason);
        Assert.Equal("y is missing.", bothInvalid.Outputs["scaled"].InvalidReason);
        Assert.Equal("x is missing.", bothInvalid.Outputs["less"].InvalidReason);
        var nonfinite = fused.EvaluateCoreCLR(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector([1d, 2d, 0d]),
            ["y"] = MathBlockValue.Vector([1d, 2d, 3d]),
            ["p"] = MathBlockValue.Scalar(2d)
        });
        Assert.Equal("The vector result contains a nonfinite value.", nonfinite.Outputs["sum"].InvalidReason);
        Assert.Equal(0b0011ul, nonfinite.InvalidMask);
        Assert.Equal([3, 4, 5, 6], fused.MaskNodeIndexes);
    }

    /// <summary>Units and types of the outputs follow the operations' type rules.</summary>
    [Fact]
    public void CoreCLROutputTypesAndUnitsEqualTheUnfusedProgram()
    {
        var metre = MathBlockUnit.Basis0;
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector(metre));
        var y = builder.Input("y", MathBlockType.Vector(metre));
        var s = builder.Input("s", MathBlockType.Scalar(metre));
        var product = builder.Apply("vector.multiply", 1, x, y);
        var quotient = builder.Apply("vector.divide", 1, product, x);
        var scaled = builder.Apply("vector.scale", 1, quotient, s);
        var shifted = builder.Apply("vector.add-scalar", 1, quotient, s);
        var root = builder.Apply("vector.square-root", 1, product);
        var sign = builder.Apply("vector.sign", 1, shifted);
        var program = builder.Output("scaled", scaled).Output("shifted", shifted).Output("root", root)
            .Output("sign", sign).Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector([1d, -2d, 3.5d, -0d], metre),
            ["y"] = MathBlockValue.Vector([4d, -2d, 0.25d, 5d], metre),
            ["s"] = MathBlockValue.Scalar(-1.5d, metre)
        };
        var fused = MathBlockFusedExpression.Create(program);
        AssertMatchesUnfused(program, inputs, None(), fused.EvaluateCoreCLR(inputs), "units");
        inputs["x"] = MathBlockValue.Vector([1d, 2d, 3.5d, 1d], metre);
        AssertMatchesUnfused(program, inputs, None(), fused.EvaluateCoreCLR(inputs), "units valid");
    }

    /// <summary>
    /// Window-valid results as validity inputs give each output the and@1 combination of the siblings that reach it.
    /// </summary>
    [Fact]
    public void CoreCLRValidityOutputsEqualTheAndOfWindowValidSiblings()
    {
        const int rows = 2_000;
        var random = new Random(17);
        var close = new double[rows];
        var volume = new double[rows];
        for (var row = 0; row < rows; row++)
        {
            close[row] = row % 97 < 20 ? 100d : 100d + random.NextDouble();
            volume[row] = 1d + random.NextDouble();
        }
        var closeValue = MathBlockValue.Vector(close);
        var volumeValue = MathBlockValue.Vector(volume);
        var width = MathBlockValue.Scalar(17d);
        var fill = MathBlockValue.Scalar(0d);
        var slope = MathBlockWindowTestSupport.Form("statistics.population-skewness")
            .Evaluate(closeValue, width, fill);
        var slopeValid = MathBlockWindowTestSupport.Validity("statistics.population-skewness").Evaluate(closeValue, width);
        var deviation = MathBlockWindowTestSupport.Form("statistics.population-standard-deviation")
            .Evaluate(volumeValue, MathBlockValue.Scalar(5d), fill);
        var deviationValid = MathBlockWindowTestSupport.Validity("statistics.population-standard-deviation")
            .Evaluate(volumeValue, MathBlockValue.Scalar(5d));
        var correlation = MathBlockWindowTestSupport.Form("statistics.pearson-correlation")
            .Evaluate(closeValue, volumeValue, width, fill);
        var correlationValid = MathBlockWindowTestSupport.Validity("statistics.pearson-correlation")
            .Evaluate(closeValue, volumeValue, width);
        Assert.Contains(false, slopeValid.AsBooleanVector());
        Assert.Contains(false, correlationValid.AsBooleanVector());

        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var a = builder.Input("skewness", MathBlockType.Vector());
        var b = builder.Input("deviation", MathBlockType.Vector());
        var c = builder.Input("correlation", MathBlockType.Vector());
        var d = builder.Input("close", MathBlockType.Vector());
        var ratio = builder.Apply("vector.divide", 1, a, builder.Apply("vector.add-scalar", 1, b,
            builder.Constant(MathBlockValue.Scalar(1d))));
        var product = builder.Apply("vector.multiply", 1, ratio, c);
        var positive = builder.Apply("vector.greater-than", 1, product, a);
        var program = builder.Output("ratio", ratio).Output("product", product).Output("positive", positive)
            .Output("close", builder.Apply("vector.absolute", 1, d)).Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["skewness"] = slope,
            ["deviation"] = deviation,
            ["correlation"] = correlation,
            ["close"] = closeValue
        };
        var validity = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["skewness"] = slopeValid,
            ["deviation"] = deviationValid,
            ["correlation"] = correlationValid
        };
        var result = MathBlockFusedExpression.Create(program).EvaluateCoreCLR(inputs, validity);
        AssertMatchesUnfused(program, inputs, validity, result, "window validity");
        var and = MathBlockCatalog.Standard.Get("boolean-vector.and");
        AssertSameValue(
            and.Evaluate(and.Evaluate(slopeValid, deviationValid), correlationValid),
            result.Validity["product"],
            "product validity");
        Assert.All(result.Validity["close"].AsBooleanVector(), Assert.True);
    }

    /// <summary>An invalid validity input makes the validity of the outputs it reaches invalid, with its reason.</summary>
    [Fact]
    public void CoreCLRInvalidValidityInputMakesReachedValidityInvalid()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector());
        var y = builder.Input("y", MathBlockType.Vector());
        var program = builder.Output("sum", builder.Apply("vector.add", 1, x, y))
            .Output("square", builder.Apply("vector.square", 1, y)).Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector([1d, 2d]),
            ["y"] = MathBlockValue.Vector([3d, 4d])
        };
        var validity = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Invalid(MathBlockType.BooleanVector(2), "The window is wider than the series."),
            ["y"] = MathBlockValue.BooleanVector([true, false])
        };
        var result = MathBlockFusedExpression.Create(program).EvaluateCoreCLR(inputs, validity);
        Assert.False(result.Validity["sum"].IsValid);
        Assert.Equal("The window is wider than the series.", result.Validity["sum"].InvalidReason);
        Assert.Equal([true, false], result.Validity["square"].AsBooleanVector());
    }

    /// <summary>The limits accept their maximum and reject one more, naming the limit and the node.</summary>
    [Fact]
    public void CreateEnforcesTheNodeInputAndOutputLimits()
    {
        MathBlockProgram Chain(int operations, int vectorInputs, int outputs)
        {
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var series = Enumerable.Range(0, vectorInputs)
                .Select(index => builder.Input($"x{index}", MathBlockType.Vector())).ToArray();
            var node = series[0];
            var created = new List<int>();
            for (var index = 0; index < operations; index++)
            {
                node = builder.Apply("vector.add", 1, node, series[(index + 1) % series.Length]);
                created.Add(node);
            }
            for (var index = 0; index < outputs; index++)
                builder.Output($"y{index}", created[created.Count - 1 - index]);
            return builder.Build();
        }

        var maximum = MathBlockFusedExpression.Create(Chain(64, 16, 4));
        Assert.Equal(64, maximum.MaskNodeIndexes.Count);
        Assert.Equal(16, maximum.VectorInputNames.Count);
        Assert.Equal(4, maximum.OutputNames.Count);

        var nodes = Assert.Throws<ArgumentException>(() => MathBlockFusedExpression.Create(Chain(65, 2, 1)));
        Assert.Contains("Operation node 66 (vector.add@1) exceeds the limit of 64 operation nodes", nodes.Message, StringComparison.Ordinal);
        var inputs = Assert.Throws<ArgumentException>(() => MathBlockFusedExpression.Create(Chain(17, 17, 1)));
        Assert.Contains("Input 'x16' (node 16) exceeds the limit of 16 vector inputs", inputs.Message, StringComparison.Ordinal);
        var outputs = Assert.Throws<ArgumentException>(() => MathBlockFusedExpression.Create(Chain(5, 2, 5)));
        Assert.Contains("has 5 outputs; a fused expression has at most 4", outputs.Message, StringComparison.Ordinal);
    }

    /// <summary>Validity inputs and outputs do not count toward the limits.</summary>
    [Fact]
    public void ValidityInputsAndOutputsDoNotCountTowardTheLimits()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var inputs = Enumerable.Range(0, 16).Select(index => builder.Input($"x{index}", MathBlockType.Vector())).ToArray();
        var node = inputs[0];
        for (var index = 1; index < 16; index++)
            node = builder.Apply("vector.add", 1, node, inputs[index]);
        var program = builder.Output("a", node).Output("b", inputs[3]).Output("c", inputs[5])
            .Output("d", builder.Apply("vector.square", 1, node)).Build();
        var fused = MathBlockFusedExpression.Create(program);
        var values = inputs.Select((_, index) => ($"x{index}", MathBlockValue.Vector([index, -index, 0.5])))
            .ToDictionary(pair => pair.Item1, pair => pair.Item2, StringComparer.Ordinal);
        var validity = inputs.Select((_, index) => ($"x{index}", MathBlockValue.BooleanVector([index != 3, true, index % 2 == 0])))
            .ToDictionary(pair => pair.Item1, pair => pair.Item2, StringComparer.Ordinal);
        var result = fused.EvaluateCoreCLR(values, validity);
        AssertMatchesUnfused(program, values, validity, result, "16 inputs with validity");
        Assert.Equal(4, result.Validity.Count);
    }

    /// <summary>Programs with operations that are not pointwise or not fusable are rejected by node.</summary>
    [Fact]
    public void CreateRejectsOperationsThatAreNotFusable()
    {
        static ArgumentException Reject(Func<MathBlockProgramBuilder, int, int> build, MathBlockType? type = null)
        {
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var x = builder.Input("x", type ?? MathBlockType.Vector());
            builder.Output("y", build(builder, x));
            return Assert.Throws<ArgumentException>(() => MathBlockFusedExpression.Create(builder.Build()));
        }

        Assert.Contains(
            "Operation node 1 (vector.cumulative-sum@1) is Expanding; a fused expression accepts only Pointwise operations.",
            Reject((builder, x) => builder.Apply("vector.cumulative-sum", 1, x)).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Operation node 2 (vector.standardize@1) is WholeSeries",
            Reject((builder, x) => builder.Apply("vector.standardize", 1, builder.Apply("vector.absolute", 1, x))).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Operation node 2 (vector.append@1) is Pointwise, but its output has one more row than its input",
            Reject((builder, x) => builder.Apply("vector.append", 1, x, builder.Constant(MathBlockValue.Scalar(1d)))).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Operation node 1 (polynomial.derivative@1) is Pointwise, but its output has one row fewer",
            Reject((builder, x) => builder.Apply("polynomial.derivative", 1, x)).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Operation node 1 (vector.sum@1) is",
            Reject((builder, x) => builder.Apply("vector.sum", 1, x)).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Operation node 1 (scalar.square@1) is NotSeries",
            Reject((builder, x) => builder.Apply("scalar.square", 1, x), MathBlockType.Scalar()).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Input 'x' (node 0) has kind ComplexVector",
            Reject((builder, x) => builder.Apply("complex-vector.real", 1, x), MathBlockType.ComplexVector()).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Constant node 1 has kind Vector",
            Reject((builder, x) => builder.Apply("vector.add", 1, x, builder.Constant(MathBlockValue.Vector([1d])))).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Output 'y' (node 1) has kind ComplexVector",
            Reject((builder, x) => builder.Apply("complex-vector.create", 1, x, x)).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "Output 'y' (node 0) has kind Scalar",
            Reject((_, x) => x, MathBlockType.Scalar()).Message,
            StringComparison.Ordinal);

        var window = MathBlockWindowTestSupport.Form("vector.sum");
        var windowed = new MathBlockRegistry(MathBlockCatalog.Standard.Operations.Append(window));
        var windowBuilder = new MathBlockProgramBuilder(windowed);
        var series = windowBuilder.Input("x", MathBlockType.Vector());
        windowBuilder.Output("y", windowBuilder.Apply("window.vector.sum", 1, series,
            windowBuilder.Constant(MathBlockValue.Scalar(3d)), windowBuilder.Constant(MathBlockValue.Scalar(0d))));
        var trailing = Assert.Throws<ArgumentException>(() => MathBlockFusedExpression.Create(windowBuilder.Build()));
        Assert.Contains("Operation node 3 (window.vector.sum@1) is Trailing", trailing.Message, StringComparison.Ordinal);
    }

    /// <summary>A Pointwise operation instance that is not the Standard one is rejected.</summary>
    [Fact]
    public void CreateRejectsAPointwiseOperationThatIsNotTheStandardInstance()
    {
        var standard = MathBlockCatalog.Standard.Get("vector.add");
        var impostor = new MathBlockOperation(
            "vector.add",
            1,
            2,
            standard.ResolveOutputType,
            inputs => standard.Evaluate(inputs[1], inputs[0]),
            standard.RegressionCases,
            standard.PerformanceCase,
            MathBlockCausalityInfo.Pointwise);
        var builder = new MathBlockProgramBuilder(new MathBlockRegistry([impostor]));
        var x = builder.Input("x", MathBlockType.Vector());
        builder.Output("y", builder.Apply("vector.add", 1, x, x));
        var exception = Assert.Throws<ArgumentException>(() => MathBlockFusedExpression.Create(builder.Build()));
        Assert.Contains("Operation node 1 (vector.add@1) is not the MathBlockCatalog.Standard operation", exception.Message, StringComparison.Ordinal);
    }

    /// <summary>Every Pointwise Standard operation is either fusable or excluded with a stated reason.</summary>
    [Fact]
    public void EveryPointwiseStandardOperationIsFusableOrExcludedWithAReason()
    {
        var supported = Operations.Select(operation => operation.Identity + "@1").ToHashSet(StringComparer.Ordinal);
        var pointwise = MathBlockCatalog.Standard.Operations
            .Where(operation => operation.Causality.Kind == MathBlockCausality.Pointwise)
            .Select(operation => operation.Identity)
            .ToArray();
        Assert.Equal(28, pointwise.Length);
        Assert.Equal(
            ["polynomial.derivative@1", "vector.append@1"],
            pointwise.Where(identity => !supported.Contains(identity)).Order(StringComparer.Ordinal),
            StringComparer.Ordinal);
        Assert.All(supported, identity => Assert.Contains(identity, pointwise, StringComparer.Ordinal));
    }

    /// <summary>Inputs of different lengths and validity inputs that do not fit are rejected.</summary>
    [Fact]
    public void EvaluateRejectsMismatchedRowsAndValidity()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector());
        var y = builder.Input("y", MathBlockType.Vector());
        var s = builder.Input("s", MathBlockType.Scalar());
        var fused = MathBlockFusedExpression.Create(
            builder.Output("z", builder.Apply("vector.scale", 1, builder.Apply("vector.add", 1, x, y), s)).Build());
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector([1d, 2d]),
            ["y"] = MathBlockValue.Vector([1d, 2d, 3d]),
            ["s"] = MathBlockValue.Scalar(1d)
        };
        Assert.Contains(
            "Vector input 'y' has 3 rows; the fused expression's vector inputs have 2.",
            Assert.Throws<ArgumentException>(() => fused.EvaluateCoreCLR(inputs)).Message,
            StringComparison.Ordinal);
        inputs["y"] = MathBlockValue.Vector([3d, 4d]);
        Assert.Contains(
            "The validity input 's' does not name a vector input",
            Assert.Throws<ArgumentException>(() => fused.EvaluateCoreCLR(
                inputs, Values(("s", MathBlockValue.BooleanVector([true, true]))))).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "The validity input of 'x' has 3 rows",
            Assert.Throws<ArgumentException>(() => fused.EvaluateCoreCLR(
                inputs, Values(("x", MathBlockValue.BooleanVector([true, true, true]))))).Message,
            StringComparison.Ordinal);
        Assert.Contains(
            "The validity input of 'x' has kind Vector",
            Assert.Throws<ArgumentException>(() => fused.EvaluateCoreCLR(
                inputs, Values(("x", MathBlockValue.Vector([1d, 1d]))))).Message,
            StringComparison.Ordinal);
        Assert.Throws<KeyNotFoundException>(() => fused.EvaluateCoreCLR(None()));
    }

    /// <summary>The fingerprint binds the program and the MathBlocks CUDA source and is stable across builds.</summary>
    [Fact]
    public void FingerprintBindsTheProgramAndTheCUDASourceAndIsStable()
    {
        static MathBlockProgram Build(string operation)
        {
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var x = builder.Input("x", MathBlockType.Vector());
            var y = builder.Input("y", MathBlockType.Vector());
            return builder.Output("z", builder.Apply(operation, 1, x, y)).Build();
        }

        var first = MathBlockFusedExpression.Create(Build("vector.add"));
        var second = MathBlockFusedExpression.Create(Build("vector.add"));
        var other = MathBlockFusedExpression.Create(Build("vector.subtract"));
        Assert.Equal(first.Fingerprint, second.Fingerprint);
        Assert.NotEqual(first.Fingerprint, other.Fingerprint, StringComparer.Ordinal);
        Assert.Equal(first.CudaSource, second.CudaSource);
        var material = "mathblocks-fused-expression-v1\n" + first.Program.Fingerprint + "\n" +
                       MathBlockCudaDeviceModule.SourceFingerprint + "\n";
        Assert.Equal(
            Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(material))),
            first.Fingerprint);
        Assert.Equal("mathblocks_fused_" + first.Fingerprint, first.CudaFunctionName);
        Assert.Equal(first.CudaFunctionName + "_kernel", first.CudaKernelName);
        Assert.True(
            string.Equals("b223bca4124eb1ebec4cef5404f690a167dfb6d700c5bd902b719a71eaa89533", first.Program.Fingerprint, StringComparison.Ordinal),
            first.Program.Fingerprint);
    }

    private static Dictionary<string, MathBlockValue> None() => new(StringComparer.Ordinal);

    private static Dictionary<string, MathBlockValue> Values(params (string Name, MathBlockValue Value)[] items) =>
        items.ToDictionary(item => item.Name, item => item.Value, StringComparer.Ordinal);

    private static (MathBlockProgram Program, Dictionary<string, MathBlockValue> Inputs) CreateSingleOperation(
        string identity,
        string arguments,
        ReadOnlySpan<double> left,
        ReadOnlySpan<double> right,
        ReadOnlySpan<bool> flags,
        double scalar)
    {
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
                    inputs[name] = MathBlockValue.Vector((numbers++ % 2 == 0 ? left : right).ToArray());
                    break;
                case 'S':
                    nodes.Add(builder.Input("s", MathBlockType.Scalar()));
                    inputs["s"] = MathBlockValue.Scalar(scalar);
                    break;
                case 'B':
                    var flag = $"b{nodes.Count}";
                    nodes.Add(builder.Input(flag, MathBlockType.BooleanVector()));
                    inputs[flag] = MathBlockValue.BooleanVector(nodes.Count % 2 == 0 ? flags.ToArray() : [.. flags.ToArray().Select(value => !value)]);
                    break;
                default:
                    nodes.Add(builder.Apply(
                        "complex-vector.create", 1,
                        builder.Input("re", MathBlockType.Vector()), builder.Input("im", MathBlockType.Vector())));
                    inputs["re"] = MathBlockValue.Vector(left.ToArray());
                    inputs["im"] = MathBlockValue.Vector(right.ToArray());
                    break;
            }
        }
        var result = builder.Apply(identity, 1, [.. nodes]);
        if (string.Equals(identity, "complex-vector.create", StringComparison.Ordinal))
        {
            // A complex vector is not a fused output, so the created value is read through both projections.
            builder.Output("imaginary", builder.Apply("complex-vector.imaginary", 1, result));
            result = builder.Apply("complex-vector.real", 1, result);
        }
        builder.Output("y", result);
        return (builder.Build(), inputs);
    }
}
