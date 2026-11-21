namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Program Tests.</summary>
public sealed class MathBlockProgramTests
{
    /// <summary>Verifies program composes generic inputs without input semantics.</summary>
    [Fact]
    public void ProgramComposesGenericInputsWithoutInputSemantics()
    {
        var unit = MathBlockUnit.Basis2;
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar(unit));
        var right = builder.Input("right", MathBlockType.Scalar(unit));
        var difference = builder.Apply("scalar.subtract", inputs: [left, right]);
        var ratio = builder.Apply("scalar.divide", inputs: [difference, right]);
        var magnitude = builder.Apply("scalar.absolute", inputs: [ratio]);
        var program = builder.Output("result", magnitude).Build();

        var output = program.Evaluate(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["left"] = MathBlockValue.Scalar(12f, unit),
            ["right"] = MathBlockValue.Scalar(10f, unit)
        });

        Assert.Equal(0.2f, output["result"].AsScalar(), 5);
        Assert.True(output["result"].Type.Unit.IsDimensionless);
    }

    /// <summary>Verifies fingerprint is stable and covers constants and topology.</summary>
    [Fact]
    public void FingerprintIsStableAndCoversConstantsAndTopology()
    {
        var first = BuildAffineProgram(2f);
        var same = BuildAffineProgram(2f);
        var changed = BuildAffineProgram(3f);

        Assert.Equal(first.Fingerprint, same.Fingerprint);
        Assert.NotEqual(first.Fingerprint, changed.Fingerprint, StringComparer.Ordinal);
        Assert.Equal(64, first.Fingerprint.Length);
    }

    /// <summary>Verifies program propagates domain invalidity.</summary>
    [Fact]
    public void ProgramPropagatesDomainInvalidity()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var numerator = builder.Input("numerator", MathBlockType.Scalar());
        var denominator = builder.Input("denominator", MathBlockType.Scalar());
        var quotient = builder.Apply("scalar.divide", inputs: [numerator, denominator]);
        var program = builder.Output("quotient", quotient).Build();

        var result = program.Evaluate(new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["numerator"] = MathBlockValue.Scalar(1f),
            ["denominator"] = MathBlockValue.Scalar(0f)
        })["quotient"];

        Assert.False(result.IsValid);
        Assert.NotEmpty(result.InvalidReason!);
    }

    /// <summary>Verifies program rejects incompatible units before execution.</summary>
    [Fact]
    public void ProgramRejectsIncompatibleUnitsBeforeExecution()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar(MathBlockUnit.Basis0));
        var right = builder.Input("right", MathBlockType.Scalar(MathBlockUnit.Basis1));

        Assert.Throws<InvalidOperationException>(() =>
            builder.Apply("scalar.add", inputs: [left, right]));
    }

    /// <summary>Verifies unknown operation version fails closed.</summary>
    [Fact]
    public void UnknownOperationVersionFailsClosed()
    {
        Assert.Throws<KeyNotFoundException>(() => MathBlockCatalog.Standard.Get("scalar.add", 2));
    }

    /// <summary>Verifies formula builder accepts blocks before their dependencies.</summary>
    [Fact]
    public void FormulaBuilderAcceptsBlocksBeforeTheirDependencies()
    {
        var formula = new MathBlockFormulaBuilder(MathBlockCatalog.Standard)
            .Block("quotient", "scalar.divide", inputs: ["left-side", "right-side"])
            .Block("right-side", "scalar.add", inputs: ["second", "third"])
            .Block("left-side", "scalar.multiply", inputs: ["first", "fourth"])
            .Input("fourth", MathBlockType.Scalar())
            .Input("third", MathBlockType.Scalar())
            .Input("second", MathBlockType.Scalar())
            .Input("first", MathBlockType.Scalar())
            .Output("result", "quotient")
            .Build();

        var result = new MathBlocksCoreCLRWorker().Execute(formula, new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["first"] = MathBlockValue.Scalar(6f),
            ["second"] = MathBlockValue.Scalar(2f),
            ["third"] = MathBlockValue.Scalar(1f),
            ["fourth"] = MathBlockValue.Scalar(4f)
        });

        Assert.Equal(8f, result["result"].AsScalar());
    }

    /// <summary>Verifies the CoreCLR worker runs independent formula branches in parallel async.</summary>
    [Fact]
    public async Task CoreCLRWorkerRunsIndependentFormulaBranchesInParallelAsync()
    {
        using var entered = new CountdownEvent(2);
        using var release = new ManualResetEventSlim();
        MathBlockOperation CreateOperation(string identifier) => new(
            identifier,
            1,
            1,
            types => types[0],
            inputs =>
            {
                entered.Signal();
                release.Wait(TimeSpan.FromSeconds(5));
                return inputs[0];
            },
            [new MathBlockRegressionCase("reference", [MathBlockValue.Scalar(1f)], MathBlockValue.Scalar(1f))],
            new MathBlockPerformanceCase([MathBlockValue.Scalar(1f)]));

        var registry = new MathBlockRegistry(
        [
            CreateOperation("test.left"),
            CreateOperation("test.right"),
            MathBlockCatalog.Standard.Get("scalar.add")
        ]);
        var builder = new MathBlockProgramBuilder(registry);
        var input = builder.Input("input", MathBlockType.Scalar());
        var left = builder.Apply("test.left", inputs: [input]);
        var right = builder.Apply("test.right", inputs: [input]);
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var program = builder.Output("sum", sum).Build();
        var worker = new MathBlocksCoreCLRWorker(2);

        var execution = System.Threading.Tasks.Task.Run(() => worker.Execute(
            program,
            new Dictionary<string, MathBlockValue>(StringComparer.Ordinal) { ["input"] = MathBlockValue.Scalar(3f) }));

        var branchesEntered = entered.Wait(TimeSpan.FromSeconds(5));
        release.Set();
        Assert.True(branchesEntered, "Both branches did not start in parallel.");
        Assert.Equal(6f, (await execution)["sum"].AsScalar());
    }

    /// <summary>Verifies the CoreCLR worker is safe for concurrent executions.</summary>
    [Fact]
    public void CoreCLRWorkerIsSafeForConcurrentExecutions()
    {
        var program = BuildAffineProgram(2f);
        var worker = new MathBlocksCoreCLRWorker();

        Parallel.For(0, 1_000, index =>
        {
            var result = worker.Execute(program, new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["input"] = MathBlockValue.Scalar(index)
            });
            Assert.Equal(index * 2f, result["output"].AsScalar());
        });
    }

    /// <summary>Verifies serial CoreCLR execution runs every node of a multi-node level.</summary>
    [Fact]
    public void SerialCoreCLRExecutionRunsEveryNodeOfAMultiNodeLevel()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var input = builder.Input("input", MathBlockType.Vector());
        var doubled = builder.Apply("vector.scale", inputs: [input, builder.Constant(MathBlockValue.Scalar(2f))]);
        var tripled = builder.Apply("vector.scale", inputs: [input, builder.Constant(MathBlockValue.Scalar(3f))]);
        var quintupled = builder.Apply("vector.scale", inputs: [input, builder.Constant(MathBlockValue.Scalar(5f))]);
        var partial = builder.Apply("vector.add", inputs: [doubled, tripled]);
        var total = builder.Apply("vector.add", inputs: [partial, quintupled]);
        var program = builder
            .Output("doubled", doubled)
            .Output("tripled", tripled)
            .Output("quintupled", quintupled)
            .Output("total", total)
            .Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["input"] = MathBlockValue.Vector([1f, 2f, 3f, 4f])
        };

        var serial = new MathBlocksCoreCLRWorker(1).Execute(program, inputs);
        var parallel = new MathBlocksCoreCLRWorker(2).Execute(program, inputs);

        var expected = new Dictionary<string, float[]>(StringComparer.Ordinal)
        {
            ["doubled"] = [2f, 4f, 6f, 8f],
            ["tripled"] = [3f, 6f, 9f, 12f],
            ["quintupled"] = [5f, 10f, 15f, 20f],
            ["total"] = [10f, 20f, 30f, 40f]
        };
        foreach (var (name, values) in expected)
        {
            Assert.True(serial[name].IsValid, $"Serial output '{name}' is invalid: {serial[name].InvalidReason}");
            Assert.Equal(values, serial[name].AsVector().ToArray());
            Assert.Equal(parallel[name].AsVector().ToArray(), serial[name].AsVector().ToArray());
        }
    }

    /// <summary>
    /// Verifies a rolling operation or difference over a known length with a constant width declares its output
    /// length, so a binary vector operation with the input rejects the mismatch at build time.
    /// </summary>
    [Theory]
    [InlineData("sequence.rolling-sum", 3f, 8)]
    [InlineData("sequence.rolling-mean", 3f, 8)]
    [InlineData("sequence.rolling-maximum", 3f, 8)]
    [InlineData("sequence.rolling-minimum", 3f, 8)]
    [InlineData("sequence.rolling-median", 3f, 8)]
    [InlineData("sequence.rolling-standard-deviation", 3f, 8)]
    [InlineData("sequence.rolling-variance", 3f, 8)]
    [InlineData("sequence.rolling-quantile", 3f, 8)]
    [InlineData("sequence.difference", 3f, 7)]
    public void ConstantWidthDeclaresTheOutputLength(string identifier, float width, int expectedRows)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var values = builder.Input("values", MathBlockType.Vector(length: 10));
        int[] arguments = string.Equals(identifier, "sequence.rolling-quantile", StringComparison.Ordinal)
            ? [values, builder.Constant(MathBlockValue.Scalar(width)), builder.Constant(MathBlockValue.Scalar(0.5f))]
            : [values, builder.Constant(MathBlockValue.Scalar(width))];
        var rolled = builder.Apply(identifier, inputs: arguments);
        var program = builder.Output("rolled", rolled).Build();

        Assert.Equal(expectedRows, program.Outputs["rolled"].Rows);
        var output = program.Evaluate(
            new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["values"] = MathBlockValue.Vector([1f, 4f, 2f, 8f, 5f, 7f, 3f, 6f, 9f, 0f])
            })["rolled"];
        Assert.True(output.IsValid);
        Assert.Equal(expectedRows, output.AsVector().Count);

        var error = Assert.Throws<InvalidOperationException>(() => builder.Apply("vector.add", inputs: [rolled, values]));
        Assert.Equal("The input row counts must be equal.", error.Message);
    }

    /// <summary>
    /// Verifies the output length stays unknown when the width is not a constant, or is outside the domain, so the
    /// evaluator decides at run time.
    /// </summary>
    [Fact]
    public void WidthOutsideTheDomainOrNotConstantLeavesTheLengthUnknown()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var values = builder.Input("values", MathBlockType.Vector(length: 4));
        var width = builder.Input("width", MathBlockType.Scalar());
        Assert.Equal(0, ApplyRows(builder, values, width));
        Assert.Equal(0, ApplyRows(builder, values, builder.Constant(MathBlockValue.Scalar(5f))));
        Assert.Equal(0, ApplyRows(builder, values, builder.Constant(MathBlockValue.Scalar(0f))));
        Assert.Equal(0, ApplyRows(builder, values, builder.Constant(MathBlockValue.Scalar(1.5f))));
        Assert.Equal(1, ApplyRows(builder, values, builder.Constant(MathBlockValue.Scalar(4f))));
        var unknown = builder.Input("unknown", MathBlockType.Vector());
        Assert.Equal(0, ApplyRows(builder, unknown, builder.Constant(MathBlockValue.Scalar(2f))));

        static int ApplyRows(MathBlockProgramBuilder builder, int values, int width)
        {
            var node = builder.Apply("sequence.rolling-sum", inputs: [values, width]);
            return builder.Output($"node-{node}", node).Build().Outputs[$"node-{node}"].Rows;
        }
    }

    /// <summary>
    /// Verifies an invalid program output has its node's planned type, even where an intermediate value has a
    /// longer run-time shape: the rolling sum's width is an input, so its length is unknown when the program is
    /// built, and the logarithm of a negative window sum is invalid.
    /// </summary>
    [Fact]
    public void InvalidProgramOutputHasItsPlannedType()
    {
        var program = BuildRollingLogarithmProgram();
        var outputs = program.Evaluate(RollingLogarithmInputs());

        Assert.False(outputs["logarithm"].IsValid);
        Assert.Equal(program.Outputs["logarithm"], outputs["logarithm"].Type);
        Assert.Equal(0, program.Outputs["logarithm"].Rows);
    }

    // input -> sequence.rolling-sum(input, width) -> vector.natural-logarithm, with the width as a program input.
    internal static MathBlockProgram BuildRollingLogarithmProgram()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var values = builder.Input("values", MathBlockType.Vector(length: 4));
        var width = builder.Input("width", MathBlockType.Scalar());
        var sums = builder.Apply("sequence.rolling-sum", inputs: [values, width]);
        return builder.Output("logarithm", builder.Apply("vector.natural-logarithm", inputs: [sums])).Build();
    }

    internal static Dictionary<string, MathBlockValue> RollingLogarithmInputs() =>
        new(StringComparer.Ordinal)
        {
            ["values"] = MathBlockValue.Vector([1f, -5f, 1f, 1f]),
            ["width"] = MathBlockValue.Scalar(2f)
        };

    private static MathBlockProgram BuildAffineProgram(float constant)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var input = builder.Input("input", MathBlockType.Scalar());
        var multiplier = builder.Constant(MathBlockValue.Scalar(constant));
        var product = builder.Apply("scalar.multiply", inputs: [input, multiplier]);
        return builder.Output("output", product).Build();
    }
}
