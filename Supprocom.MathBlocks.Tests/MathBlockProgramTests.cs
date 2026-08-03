using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockProgramTests
{
    [Fact]
    public void Program_composes_generic_inputs_without_input_semantics()
    {
        var unit = MathBlockUnit.Basis2;
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar(unit));
        var right = builder.Input("right", MathBlockType.Scalar(unit));
        var difference = builder.Apply("scalar.subtract", inputs: [left, right]);
        var ratio = builder.Apply("scalar.divide", inputs: [difference, right]);
        var magnitude = builder.Apply("scalar.absolute", inputs: [ratio]);
        var program = builder.Output("result", magnitude).Build();

        var output = program.Evaluate(new Dictionary<string, MathBlockValue>
        {
            ["left"] = MathBlockValue.Scalar(12d, unit),
            ["right"] = MathBlockValue.Scalar(10d, unit)
        });

        Assert.Equal(0.2d, output["result"].AsScalar(), 12);
        Assert.True(output["result"].Type.Unit.IsDimensionless);
    }

    [Fact]
    public void Fingerprint_is_stable_and_covers_constants_and_topology()
    {
        var first = BuildAffineProgram(2d);
        var same = BuildAffineProgram(2d);
        var changed = BuildAffineProgram(3d);

        Assert.Equal(first.Fingerprint, same.Fingerprint);
        Assert.NotEqual(first.Fingerprint, changed.Fingerprint);
        Assert.Equal(64, first.Fingerprint.Length);
    }

    [Fact]
    public void Program_propagates_domain_invalidity()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var numerator = builder.Input("numerator", MathBlockType.Scalar());
        var denominator = builder.Input("denominator", MathBlockType.Scalar());
        var quotient = builder.Apply("scalar.divide", inputs: [numerator, denominator]);
        var program = builder.Output("quotient", quotient).Build();

        var result = program.Evaluate(new Dictionary<string, MathBlockValue>
        {
            ["numerator"] = MathBlockValue.Scalar(1d),
            ["denominator"] = MathBlockValue.Scalar(0d)
        })["quotient"];

        Assert.False(result.IsValid);
        Assert.NotEmpty(result.InvalidReason!);
    }

    [Fact]
    public void Program_rejects_incompatible_units_before_execution()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar(MathBlockUnit.Basis0));
        var right = builder.Input("right", MathBlockType.Scalar(MathBlockUnit.Basis1));

        Assert.Throws<InvalidOperationException>(() =>
            builder.Apply("scalar.add", inputs: [left, right]));
    }

    [Fact]
    public void Unknown_operation_version_fails_closed()
    {
        Assert.Throws<KeyNotFoundException>(() => MathBlockCatalog.Standard.Get("scalar.add", 2));
    }

    [Fact]
    public void Formula_builder_accepts_blocks_before_their_dependencies()
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

        var result = new MathBlocksCPUWorker().Execute(formula, new Dictionary<string, MathBlockValue>
        {
            ["first"] = MathBlockValue.Scalar(6d),
            ["second"] = MathBlockValue.Scalar(2d),
            ["third"] = MathBlockValue.Scalar(1d),
            ["fourth"] = MathBlockValue.Scalar(4d)
        });

        Assert.Equal(8d, result["result"].AsScalar());
    }

    [Fact]
    public async Task CPU_worker_runs_independent_formula_branches_in_parallel()
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
            [new MathBlockRegressionCase("reference", [MathBlockValue.Scalar(1d)], MathBlockValue.Scalar(1d))],
            new MathBlockPerformanceCase([MathBlockValue.Scalar(1d)]));

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
        var worker = new MathBlocksCPUWorker(2);

        var execution = System.Threading.Tasks.Task.Run(() => worker.Execute(
            program,
            new Dictionary<string, MathBlockValue> { ["input"] = MathBlockValue.Scalar(3d) }));

        var branchesEntered = entered.Wait(TimeSpan.FromSeconds(5));
        release.Set();
        Assert.True(branchesEntered, "Both branches did not start in parallel.");
        Assert.Equal(6d, (await execution)["sum"].AsScalar());
    }

    [Fact]
    public void CPU_worker_is_safe_for_concurrent_executions()
    {
        var program = BuildAffineProgram(2d);
        var worker = new MathBlocksCPUWorker();

        Parallel.For(0, 1_000, index =>
        {
            var result = worker.Execute(program, new Dictionary<string, MathBlockValue>
            {
                ["input"] = MathBlockValue.Scalar(index)
            });
            Assert.Equal(index * 2d, result["output"].AsScalar());
        });
    }

    private static MathBlockProgram BuildAffineProgram(double constant)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var input = builder.Input("input", MathBlockType.Scalar());
        var multiplier = builder.Constant(MathBlockValue.Scalar(constant));
        var product = builder.Apply("scalar.multiply", inputs: [input, multiplier]);
        return builder.Output("output", product).Build();
    }
}
