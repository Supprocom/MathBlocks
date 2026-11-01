using Xunit.Abstractions;
using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;
using static Supprocom.MathBlocks.Tests.MathBlockFusedTestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Checks the fused expression's CoreCLR reference on programs with elementwise forms and siblings.</summary>
public sealed class MathBlockFusedExpressionElementwiseTests(ITestOutputHelper output)
{
    // Signed zeros, subnormals and the smallest normal of both signs, and values on the common domain edges.
    internal static readonly double[] SignedEdgeValues =
    [
        0d, -0d, double.Epsilon, -double.Epsilon, 1e-310d, -1e-310d, 2.2250738585072014E-308d,
        -2.2250738585072014E-308d, 1d, -1d, 0.5d, 2d, 3d
    ];

    // The broadcast scalars of the edge grid, and the fills: negative zero, a subnormal and an ordinary value.
    internal static readonly double[] GridScalars = [-0d, 1e-310d, 2d];

    /// <summary>
    /// Random programs within the limits that mix elementwise forms and siblings with the other pointwise operations
    /// give the unfused program's outputs bit for bit, with its invalid state, reasons and row validity.
    /// </summary>
    [Fact]
    public void CoreCLRRandomProgramsWithElementwiseFormsEqualTheUnfusedProgramBitForBit()
    {
        const int trials = 240;
        var random = new Random(20261101);
        var ran = 0;
        var undefined = 0;
        var counts = new FormRowCounts();
        for (var trial = 0; trial < trials; trial++)
        {
            var program = CreateRandomProgram(
                random,
                vectorInputs: random.Next(1, 7),
                booleanInputs: random.Next(0, 3),
                scalarInputs: random.Next(0, 3),
                operations: random.Next(1, MathBlockFusedExpression.MaximumOperationNodes + 1),
                outputs: random.Next(1, MathBlockFusedExpression.MaximumOutputs + 1),
                elementwisePercent: 40);
            var fused = MathBlockFusedExpression.Create(program);
            var regime = (Regime)(trial % 3);
            var rows = trial % 7 == 0 ? random.Next(0, 3) : random.Next(1, 400);
            var inputs = CreateInputs(program, rows, regime, random);
            var validity = CreateValidity(program, rows, random);
            undefined += AssertMatchesUnfused(
                program,
                inputs,
                validity,
                fused.EvaluateCoreCLR(inputs, validity),
                $"trial {trial} ({regime}, {rows} rows)");
            counts.Add(program, inputs);
            ran++;
        }

        output.WriteLine($"{ran} programs, {counts}, {undefined} outputs without a row-validity reference");
        Assert.Equal(trials, ran);
        // Guards against a generator that never exercises the fill: some valid form must hold its fill.
        Assert.True(counts.FilledRows > 0, $"No filled row of a valid form was compared: {counts}.");
    }

    /// <summary>Random programs with elementwise forms give the unfused outputs at the full row count, 302,893.</summary>
    [Fact]
    public void CoreCLRRandomProgramsWithElementwiseFormsEqualTheUnfusedProgramAtFullRowCount()
    {
        const int trials = 4;
        var random = new Random(302_893 + 4);
        var counts = new FormRowCounts();
        var ran = 0;
        for (var trial = 0; trial < trials; trial++)
        {
            var program = CreateRandomProgram(
                random, 4, 1, 1, trial == 0 ? MathBlockFusedExpression.MaximumOperationNodes : random.Next(8, 40), 4,
                elementwisePercent: 50);
            var fused = MathBlockFusedExpression.Create(program);
            var regime = trial == 3 ? Regime.Signed : Regime.Benign;
            var inputs = CreateInputs(program, FullRows, regime, random);
            var validity = CreateValidity(program, FullRows, random);
            AssertMatchesUnfused(
                program, inputs, validity, fused.EvaluateCoreCLR(inputs, validity), $"full trial {trial} ({regime})");
            counts.Add(program, inputs);
            ran++;
        }
        output.WriteLine($"{ran} programs at {FullRows} rows, {counts}");
        Assert.Equal(trials, ran);
    }

    /// <summary>
    /// Every form and sibling under every broadcast mask gives the unfused bits on seeded rows from the elementwise
    /// edge mix and on the grid of signed zeros, subnormals and domain edges, with fills -0, a subnormal and 2.
    /// </summary>
    [Fact]
    public void CoreCLREveryFormAndBroadcastMaskEqualsTheUnfusedProgramOnEdgeRows()
    {
        var cases = 0;
        var expectedCases = 0;
        var notFilled = new List<string>();
        var notComputed = new List<string>();
        foreach (var source in SourceIdentifiers)
        {
            var filled = 0;
            var computed = 0;
            foreach (var mask in BroadcastMasks(source))
            {
                foreach (var (name, program, inputs, validity) in CreateEdgeCases(source, mask))
                {
                    var fused = MathBlockFusedExpression.Create(program);
                    AssertMatchesUnfused(program, inputs, validity, fused.EvaluateCoreCLR(inputs, validity), name);
                    var flags = program.Evaluate(inputs)["valid"].AsBooleanVector();
                    filled += flags.Count(flag => !flag);
                    computed += flags.Count(flag => flag);
                    cases++;
                }
                expectedCases += EdgeCasesPerMask;
            }
            if (filled == 0)
                notFilled.Add(source);
            if (computed == 0)
                notComputed.Add(source);
        }

        output.WriteLine($"{cases} edge cases over {SourceIdentifiers.Length} sources and every broadcast mask");
        output.WriteLine($"fill not exercised (the source is valid on every row drawn): {string.Join(", ", notFilled)}");
        Assert.Equal(expectedCases, cases);
        Assert.Empty(notComputed);
    }

    /// <summary>
    /// Invalid vector, scalar and fill inputs, and nonfinite rows of an earlier node, give the unfused invalid state
    /// and reasons; the forms and siblings never set their mask bits.
    /// </summary>
    [Fact]
    public void CoreCLRInvalidInputsAndNonfiniteRowsFollowTheUnfusedProgram()
    {
        var (program, fused) = CreateInvalidStateProgram();
        var undefined = 0;
        foreach (var (name, inputs) in CreateInvalidStateCases())
        {
            var result = fused.EvaluateCoreCLR(inputs);
            undefined += AssertMatchesUnfused(program, inputs, new Dictionary<string, MathBlockValue>(StringComparer.Ordinal), result, name);
            for (var bit = 0; bit < fused.MaskNodeIndexes.Count; bit++)
            {
                var node = program.PlanNodes[fused.MaskNodeIndexes[bit]];
                if (node.OperationIdentity!.StartsWith("elementwise", StringComparison.Ordinal))
                    Assert.True((result.InvalidMask & (1ul << bit)) == 0, $"{name}: mask bit {bit} of {node.OperationIdentity}.");
            }
        }

        var nonfinite = fused.EvaluateCoreCLR(CreateInvalidStateCases().Single(item => string.Equals(item.Name, "zero divisor", StringComparison.Ordinal)).Inputs);
        Assert.Equal(1ul, nonfinite.InvalidMask);
        Assert.Equal("The vector result contains a nonfinite value.", nonfinite.Outputs["tangent"].InvalidReason);
        Assert.True(nonfinite.Outputs["clamped"].IsValid);
        output.WriteLine($"{undefined} outputs without a row-validity reference");
    }

    /// <summary>
    /// A filled row holds the fill's bits and is not valid in the outputs it reaches; the sibling marks it false, and
    /// the validity inputs combine with it.
    /// </summary>
    [Fact]
    public void CoreCLRFilledRowsHoldTheFillBitsAndAreNotValid()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector());
        var fill = builder.Input("fill", MathBlockType.Scalar());
        var logit = builder.Apply("elementwise.scalar.logit", 1, x, fill);
        var computed = builder.Apply("elementwise-valid.scalar.logit", 1, x);
        var absolute = builder.Apply("vector.absolute", 1, logit);
        var program = builder.Output("logit", logit).Output("computed", computed).Output("absolute", absolute).Build();
        var fused = MathBlockFusedExpression.Create(program);
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector([0.25d, 0d, 1d, 2d, -0d, 0.75d]),
            ["fill"] = MathBlockValue.Scalar(-0d)
        };
        var validity = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.BooleanVector([true, true, true, true, true, false])
        };
        var result = fused.EvaluateCoreCLR(inputs, validity);
        AssertMatchesUnfused(program, inputs, validity, result, "filled rows");
        var values = result.Outputs["logit"].AsVector();
        foreach (var row in new[] { 1, 2, 3, 4 })
            Assert.Equal(0x8000000000000000ul, BitConverter.DoubleToUInt64Bits(values[row]));
        Assert.Equal([true, false, false, false, false, true], result.Outputs["computed"].AsBooleanVector());
        Assert.Equal([true, false, false, false, false, false], result.Validity["logit"].AsBooleanVector());
        Assert.Equal([true, false, false, false, false, false], result.Validity["absolute"].AsBooleanVector());
        Assert.Equal([true, true, true, true, true, false], result.Validity["computed"].AsBooleanVector());
        Assert.Equal(0ul, result.InvalidMask);
    }

    /// <summary>Forms keep the units of their sources, and the outputs' types equal the unfused program's.</summary>
    [Fact]
    public void CoreCLRElementwiseFormsKeepUnits()
    {
        var metre = MathBlockUnit.Basis0;
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector(metre));
        var lower = builder.Input("lower", MathBlockType.Scalar(metre));
        var upper = builder.Input("upper", MathBlockType.Vector(metre));
        var fill = builder.Input("fill", MathBlockType.Scalar(metre));
        var negated = builder.Apply("elementwise.scalar.negate", 1, x, fill);
        var larger = builder.Apply("elementwise.scalar.maximum", 1, negated, lower, fill);
        var clamped = builder.Apply("elementwise.scalar.clamp", 1, larger, lower, upper, fill);
        var floored = builder.Apply("elementwise.scalar.floor", 1, clamped, fill);
        var program = builder.Output("negated", negated).Output("clamped", clamped).Output("floored", floored)
            .Output("valid", builder.Apply("elementwise-valid.scalar.clamp", 1, larger, lower, upper)).Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector([1.5d, -2d, -0d, 4d, 0d], metre),
            ["lower"] = MathBlockValue.Scalar(-0d, metre),
            ["upper"] = MathBlockValue.Vector([3d, 1d, 0d, -1d, 0d], metre),
            ["fill"] = MathBlockValue.Scalar(-7.25d, metre)
        };
        var result = MathBlockFusedExpression.Create(program).EvaluateCoreCLR(inputs);
        AssertMatchesUnfused(program, inputs, new Dictionary<string, MathBlockValue>(StringComparer.Ordinal), result, "units");
        Assert.Equal(MathBlockType.Vector(metre, 5), result.Outputs["floored"].Type);
        Assert.Contains(false, result.Outputs["valid"].AsBooleanVector());
    }

    /// <summary>Every elementwise form and sibling of the registry can be fused, and they are Pointwise.</summary>
    [Fact]
    public void EveryElementwiseFormAndSiblingIsFusable()
    {
        var fusable = 0;
        foreach (var operation in Elementwise.Operations)
        {
            Assert.Equal(MathBlockCausality.Pointwise, operation.Causality.Kind);
            var sibling = operation.Identifier.StartsWith("elementwise-valid.", StringComparison.Ordinal);
            var source = operation.Identifier[(sibling ? "elementwise-valid." : "elementwise.").Length..];
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var arguments = Enumerable.Range(0, SourceArity(source))
                .Select(index => builder.Input($"x{index}", MathBlockType.Vector())).ToList();
            if (!sibling)
                arguments.Add(builder.Constant(MathBlockValue.Scalar(-1d)));
            var program = builder.Output("y", builder.Apply(operation.Identifier, 1, [.. arguments])).Build();
            var fused = MathBlockFusedExpression.Create(program);
            Assert.Single(fused.MaskNodeIndexes);
            fusable++;
        }
        Assert.Equal(ElementwiseFeatureCount, fusable);
    }

    /// <summary>An elementwise operation instance that is not the registry's own is rejected.</summary>
    [Fact]
    public void CreateRejectsAnElementwiseInstanceThatIsNotTheRegistryOne()
    {
        var registered = Form("scalar.cosine");
        var impostor = new MathBlockOperation(
            registered.Identifier,
            1,
            registered.Arity,
            registered.ResolveOutputType,
            registered.Evaluate,
            registered.RegressionCases,
            registered.PerformanceCase,
            MathBlockCausalityInfo.Pointwise);
        var builder = new MathBlockProgramBuilder(new MathBlockRegistry([impostor]));
        var x = builder.Input("x", MathBlockType.Vector());
        builder.Output("y", builder.Apply(registered.Identifier, 1, x, builder.Constant(MathBlockValue.Scalar(0d))));
        var exception = Assert.Throws<ArgumentException>(() => MathBlockFusedExpression.Create(builder.Build()));
        Assert.Contains(
            "Operation node 2 (elementwise.scalar.cosine@1) is not the MathBlockCatalog.Standard operation",
            exception.Message,
            StringComparison.Ordinal);
    }

    // The 41 sources, each with a form and a sibling.
    internal const int ElementwiseFeatureCount = 82;

    // Per source and mask: seeded rows with fill -0, then the edge grid with each grid scalar as every broadcast
    // scalar and as the fill.
    internal const int EdgeCasesPerMask = 4;

    // Seeded edge-mix rows, then the grid of SignedEdgeValues over the vector arguments (13, 169 or 2,197 rows)
    // with each GridScalars value as the broadcast scalars and the fill. The program outputs the form, its sibling
    // and a select between the form and another vector input on the sibling, which has a validity input.
    internal static IEnumerable<(string Name, MathBlockProgram Program, Dictionary<string, MathBlockValue> Inputs,
        Dictionary<string, MathBlockValue> Validity)> CreateEdgeCases(string source, int mask)
    {
        var arity = SourceArity(source);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var arguments = new int[arity];
        for (var index = 0; index < arity; index++)
            arguments[index] = builder.Input(
                $"a{index}", (mask >> index & 1) != 0 ? MathBlockType.Vector() : MathBlockType.Scalar());
        var other = builder.Input("other", MathBlockType.Vector());
        var fill = builder.Input("fill", MathBlockType.Scalar());
        var form = builder.Apply($"elementwise.{source}", 1, [.. arguments, fill]);
        var valid = builder.Apply($"elementwise-valid.{source}", 1, arguments);
        var program = builder.Output("form", form).Output("valid", valid)
            .Output("selected", builder.Apply("vector.select", 1, valid, form, other)).Build();
        var label = $"{source} mask {DescribeMask(source, mask)}";

        var seeded = CreateArguments(source, 2_000, mask, 52_000 + mask);
        yield return ($"{label} seeded", program, Bind(seeded, -0d, 2_000), RowValidity(2_000, mask));

        var vectors = Enumerable.Range(0, arity).Count(index => (mask >> index & 1) != 0);
        var rows = (int)Math.Pow(SignedEdgeValues.Length, vectors);
        foreach (var scalar in GridScalars)
        {
            var grid = new MathBlockValue[arity];
            var ordinal = 0;
            for (var index = 0; index < arity; index++)
            {
                if ((mask >> index & 1) == 0)
                {
                    grid[index] = MathBlockValue.Scalar(scalar);
                    continue;
                }
                var stride = (int)Math.Pow(SignedEdgeValues.Length, ordinal++);
                grid[index] = MathBlockValue.Vector(Enumerable.Range(0, rows)
                    .Select(row => SignedEdgeValues[row / stride % SignedEdgeValues.Length]).ToArray());
            }
            yield return ($"{label} grid scalar {scalar:R}", program, Bind(grid, scalar, rows), RowValidity(rows, mask));
        }

        Dictionary<string, MathBlockValue> Bind(MathBlockValue[] values, double fillValue, int count)
        {
            var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                ["other"] = MathBlockValue.Vector(Enumerable.Range(0, count).Select(row => row * 0.25d - 3d).ToArray()),
                ["fill"] = MathBlockValue.Scalar(fillValue)
            };
            for (var index = 0; index < values.Length; index++)
                inputs[$"a{index}"] = values[index];
            return inputs;
        }

        Dictionary<string, MathBlockValue> RowValidity(int count, int vectorMask)
        {
            var first = Enumerable.Range(0, arity).First(index => (vectorMask >> index & 1) != 0);
            return new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
            {
                [$"a{first}"] = MathBlockValue.BooleanVector(Enumerable.Range(0, count).Select(row => row % 11 != 3))
            };
        }
    }

    // x / y can be nonfinite; the arc-tangent form of the quotient, a clamp with a broadcast lower limit, a logit
    // sibling, and a form whose argument is another form.
    internal static (MathBlockProgram Program, MathBlockFusedExpression Fused) CreateInvalidStateProgram()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector());
        var y = builder.Input("y", MathBlockType.Vector());
        var s = builder.Input("s", MathBlockType.Scalar());
        var fill = builder.Input("fill", MathBlockType.Scalar());
        var quotient = builder.Apply("vector.divide", 1, x, y);
        var tangent = builder.Apply("elementwise.scalar.arc-tangent", 1, quotient, fill);
        var clamped = builder.Apply("elementwise.scalar.clamp", 1, x, s, y, fill);
        var logit = builder.Apply("elementwise-valid.scalar.logit", 1, x);
        var nested = builder.Apply("elementwise.scalar.inverse-hyperbolic-tangent", 1, tangent, fill);
        var program = builder.Output("tangent", tangent).Output("clamped", clamped).Output("logit", logit)
            .Output("nested", nested).Build();
        return (program, MathBlockFusedExpression.Create(program));
    }

    internal static IEnumerable<(string Name, Dictionary<string, MathBlockValue> Inputs)> CreateInvalidStateCases()
    {
        static Dictionary<string, MathBlockValue> Inputs(MathBlockValue x, MathBlockValue y, MathBlockValue s, MathBlockValue fill) =>
            new(StringComparer.Ordinal) { ["x"] = x, ["y"] = y, ["s"] = s, ["fill"] = fill };

        var x = MathBlockValue.Vector([0.25d, -0.5d, 2d, 0.75d]);
        var y = MathBlockValue.Vector([1d, 2d, -1d, 0.5d]);
        var s = MathBlockValue.Scalar(0d);
        var fill = MathBlockValue.Scalar(-0.5d);
        yield return ("valid", Inputs(x, y, s, fill));
        yield return ("zero divisor", Inputs(x, MathBlockValue.Vector([1d, 0d, -1d, 0.5d]), s, fill));
        yield return ("invalid x", Inputs(MathBlockValue.Invalid(MathBlockType.Vector(), "x is missing."), y, s, fill));
        yield return ("invalid y", Inputs(x, MathBlockValue.Invalid(MathBlockType.Vector(), "y is missing."), s, fill));
        yield return ("invalid s", Inputs(x, y, MathBlockValue.Invalid(MathBlockType.Scalar(), "s is missing."), fill));
        yield return ("invalid fill", Inputs(x, y, s, MathBlockValue.Invalid(MathBlockType.Scalar(), "fill is missing.")));
        yield return ("invalid x and fill", Inputs(
            MathBlockValue.Invalid(MathBlockType.Vector(), "x is missing."), y, s,
            MathBlockValue.Invalid(MathBlockType.Scalar(), "fill is missing.")));
        yield return ("zero divisor and invalid fill", Inputs(
            x, MathBlockValue.Vector([0d, 0d, -1d, 0.5d]), s,
            MathBlockValue.Invalid(MathBlockType.Scalar(), "fill is missing.")));
    }

    // Computed and filled rows of the valid elementwise forms of the unfused programs.
    internal sealed class FormRowCounts
    {
        public int Forms { get; private set; }
        public long ComputedRows { get; private set; }
        public long FilledRows { get; private set; }

        public void Add(MathBlockProgram program, IReadOnlyDictionary<string, MathBlockValue> inputs)
        {
            MathBlockValue[]? values = null;
            foreach (var node in program.PlanNodes)
            {
                if (node.OperationIdentity is not { } identity ||
                    !identity.StartsWith("elementwise.", StringComparison.Ordinal))
                    continue;
                values ??= EvaluateNodes(program, inputs);
                Forms++;
                if (!values[node.Index].IsValid)
                    continue;
                var flags = Operation("elementwise-valid." + identity["elementwise.".Length..])
                    .Evaluate([.. node.Inputs.Take(node.Inputs.Count - 1).Select(input => values[input])])
                    .AsBooleanVector();
                ComputedRows += flags.Count(flag => flag);
                FilledRows += flags.Count(flag => !flag);
            }
        }

        public override string ToString() =>
            $"{Forms} form nodes, {ComputedRows} computed and {FilledRows} filled rows of valid forms";
    }
}
