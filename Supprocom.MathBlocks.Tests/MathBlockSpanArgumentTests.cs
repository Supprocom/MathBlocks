using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains tests for the evaluation on span arguments: equality with the evaluation on values, allocations and spans that are too short.</summary>
public sealed class MathBlockSpanArgumentTests
{
    private const int OutputSize = 2048;
    // The generator makes eight random cases (four lengths, signed and positive) and two edge cases for every shape of every operation,
    // before the cases that depend on the arguments, so a shape that produced fewer than ten cases has lost its generator.
    private const int MinimumCases = 10;
    private const string ElementwiseFormPrefix = "elementwise.";
    private const string ElementwiseValidityPrefix = "elementwise-valid.";

    private static readonly int[] Lengths = [0, 1, 17, 1000];
    private static readonly double[] EdgeValues = [0d, -0d, double.Epsilon, -double.Epsilon, double.MaxValue, -double.MaxValue, 1e308d, -1e308d, 2.2250738585072009e-308d, 1d, -1d, 0.5d];
    private static readonly double[] ScalarPool = [0d, 1d, 2d, 3d, 0.5d, -1d, 17d, 7.25d, 1e308d, -0d, double.Epsilon];
    private static readonly double[] BadValues = [double.NaN, double.PositiveInfinity, double.NegativeInfinity];

    // The operations that run on a span kernel, with the argument shapes the cases use: V a vector, S a scalar, F a Boolean vector.
    private static readonly Dictionary<string, string[]> CoveredShapes = new(StringComparer.Ordinal)
    {
        ["vector.absolute"] = ["V"],
        ["vector.sign"] = ["V"],
        ["vector.positive-part"] = ["V"],
        ["vector.square"] = ["V"],
        ["vector.square-root"] = ["V"],
        ["vector.exponential"] = ["V"],
        ["vector.natural-logarithm"] = ["V"],
        ["vector.standardize"] = ["V"],
        ["vector.add"] = ["VV"],
        ["vector.subtract"] = ["VV"],
        ["vector.multiply"] = ["VV"],
        ["vector.divide"] = ["VV"],
        ["vector.greater-than"] = ["VV"],
        ["vector.less-than"] = ["VV"],
        ["vector.equal"] = ["VV"],
        ["vector.scale"] = ["VS"],
        ["vector.add-scalar"] = ["VS"],
        ["vector.power"] = ["VS"],
        ["vector.repeat"] = ["SS"],
        ["vector.select"] = ["FVV"],
        ["boolean-vector.and"] = ["FF"],
        ["boolean-vector.or"] = ["FF"],
        ["boolean-vector.xor"] = ["FF"],
        ["boolean-vector.not"] = ["F"]
    };

    // Operations without a span kernel, which take the allocating evaluation; the tests check them for equality and for a short output.
    private static readonly Dictionary<string, string[]> FallbackShapes = new(StringComparer.Ordinal)
    {
        ["vector.sort"] = ["V"],
        ["vector.cumulative-sum"] = ["V"],
        ["vector.reverse"] = ["V"],
        ["vector.normalize-l1"] = ["V"],
        ["vector.concatenate"] = ["VV"],
        ["vector.slice"] = ["VSS"],
        ["vector.linspace"] = ["SSS"],
        ["sequence.rolling-mean"] = ["VS"]
    };

    // The sources of elementwise forms whose rows have no kernel, so the form and its validity sibling take the allocating evaluation.
    private static readonly HashSet<string> FallbackSources = new(StringComparer.Ordinal)
    {
        "combinatorics.ballot-count",
        "combinatorics.binomial-coefficient",
        "combinatorics.factorial",
        "probability.poisson-cdf",
        "probability.poisson-pmf",
        "scalar.clamp",
        "special.regularized-incomplete-beta"
    };

    /// <summary>Lists every operation the span arguments are checked on for equality with the evaluation on values.</summary>
    public static TheoryData<string> EqualityOperations()
    {
        var data = new TheoryData<string>();
        foreach (var identifier in CoveredShapes.Keys)
            data.Add(identifier);
        foreach (var identifier in FallbackShapes.Keys)
            data.Add(identifier);
        foreach (var identifier in ElementwiseIdentifiers())
            data.Add(identifier);
        return data;
    }

    /// <summary>Lists the operations that run on a span kernel.</summary>
    public static TheoryData<string> KernelOperations()
    {
        var data = new TheoryData<string>();
        foreach (var identifier in CoveredShapes.Keys)
            data.Add(identifier);
        foreach (var identifier in ElementwiseIdentifiers())
            if (!FallbackSources.Contains(SourceOf(identifier)))
                data.Add(identifier);
        return data;
    }

    /// <summary>Lists every operation whose span evaluation is checked for a short output.</summary>
    public static TheoryData<string> ShortOutputOperations() => EqualityOperations();

    /// <summary>Verifies the arguments evaluate to the bits and the validity of the evaluation on values, for every operation of the lists.</summary>
    [Theory]
    [MemberData(nameof(EqualityOperations))]
    public void SpanArgumentsEqualTheEvaluationOnValues(string identifier)
    {
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var contract = MathBlockCudaDeviceModule.GetOperation(operation.Identity);
        var random = new Random(SeedOf(identifier, 20260));
        var cases = 0;
        foreach (var shape in ShapesOf(identifier))
        {
            foreach (var (label, operands) in Cases(operation, shape, random))
            {
                AssertEqualsEvaluation(operation, contract, operands, identifier + " " + label);
                cases++;
            }
        }

        Assert.True(cases >= MinimumCases, identifier);
    }

    /// <summary>Verifies the per-row overloads give the form and its validity sibling, for every elementwise form with at most three arguments.</summary>
    [Theory]
    [MemberData(nameof(EqualityOperations))]
    public void PerRowSpanArgumentsEqualTheFormAndItsSibling(string identifier)
    {
        if (!IsForm(identifier))
            return;
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var contract = MathBlockCudaDeviceModule.GetOperation(operation.Identity);
        var sibling = MathBlockCatalog.Standard.Get(ElementwiseValidityPrefix + identifier[ElementwiseFormPrefix.Length..], 1);
        var random = new Random(SeedOf(identifier, 77));
        var cases = 0;
        foreach (var shape in ShapesOf(identifier))
        {
            foreach (var (label, operands) in Cases(operation, shape, random))
            {
                AssertRowsEqualFormAndSibling(operation, contract, sibling, operands, identifier + " " + label);
                cases++;
            }
        }

        Assert.True(cases >= MinimumCases, identifier);
    }

    /// <summary>Verifies a warm call allocates no bytes on the thread, for every operation that runs on a span kernel.</summary>
    [Theory]
    [MemberData(nameof(KernelOperations))]
    public void WarmCallsAllocateNothing(string identifier)
    {
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var contract = MathBlockCudaDeviceModule.GetOperation(operation.Identity);
        var output = new double[OutputSize];
        var rowValid = new bool[OutputSize];
        foreach (var shape in ShapesOf(identifier))
        {
            foreach (var length in new[] { 17, 1000 })
            {
                var operands = Benign(identifier, shape, length);
                var label = identifier + " " + shape + " " + length.ToString(CultureInfo.InvariantCulture);
                Assert.True(MeasureAllocation(operation, operands, output) == 0L, label + " (operation)");
                Assert.True(MeasureAllocation(contract, operands, output) == 0L, label + " (contract)");
                if (!IsForm(identifier))
                    continue;
                Assert.True(MeasureAllocation(operation, operands, output, rowValid) == 0L, label + " (operation, per row)");
                Assert.True(MeasureAllocation(contract, operands, output, rowValid) == 0L, label + " (contract, per row)");
            }
        }
    }

    /// <summary>Verifies an output span that is too short throws an argument exception that names the needed length.</summary>
    [Theory]
    [MemberData(nameof(ShortOutputOperations))]
    public void AShortOutputThrowsAndNamesTheNeededLength(string identifier)
    {
        var operation = MathBlockCatalog.Standard.Get(identifier, 1);
        var contract = MathBlockCudaDeviceModule.GetOperation(operation.Identity);
        foreach (var shape in ShapesOf(identifier))
        {
            var operands = Benign(identifier, shape, 5);
            var expected = operation.Evaluate(ValuesOf(operands));
            Assert.True(expected.IsValid, identifier);
            var rows = expected.Type.Kind == MathBlockValueKind.BooleanVector ? expected.AsBooleanVector().Count : expected.AsVector().Count;
            Assert.True(rows > 0, identifier);
            var needed = "needs " + rows.ToString(CultureInfo.InvariantCulture) + " elements";
            var shortOutput = new double[rows - 1];

            var thrown = Assert.Throws<ArgumentException>(() => Run(operation, operands, shortOutput));
            Assert.Contains(needed, thrown.Message, StringComparison.Ordinal);
            Assert.Equal("output", thrown.ParamName);
            thrown = Assert.Throws<ArgumentException>(() => Run(contract, operands, shortOutput));
            Assert.Contains(needed, thrown.Message, StringComparison.Ordinal);
            Assert.Equal("output", thrown.ParamName);
            Assert.Equal(rows, Run(operation, operands, new double[rows]).Rows);
            if (!IsForm(identifier))
                continue;
            thrown = Assert.Throws<ArgumentException>(() => RunRows(operation, operands, shortOutput, new bool[rows]));
            Assert.Contains(needed, thrown.Message, StringComparison.Ordinal);
            Assert.Equal("output", thrown.ParamName);
            thrown = Assert.Throws<ArgumentException>(() => RunRows(contract, operands, new double[rows], new bool[rows - 1]));
            Assert.Contains(needed, thrown.Message, StringComparison.Ordinal);
            Assert.Equal("rowValid", thrown.ParamName);
            Assert.Equal(rows, RunRows(operation, operands, new double[rows], new bool[rows]).Rows);
        }
    }

    /// <summary>Verifies the factories keep the kind and the unit, and a default argument is refused.</summary>
    [Fact]
    public void FactoriesKeepKindAndUnitAndADefaultArgumentIsRefused()
    {
        var scalar = MathBlockSpanArgument.Scalar(1.5d, MathBlockUnit.Basis1);
        var vector = MathBlockSpanArgument.Vector([1d, 2d], MathBlockUnit.Basis2);
        var flags = MathBlockSpanArgument.BooleanVector([true, false]);
        var plain = MathBlockSpanArgument.Vector([1d]);

        Assert.Equal(MathBlockValueKind.Scalar, scalar.Kind);
        Assert.Equal(MathBlockUnit.Basis1, scalar.Unit);
        Assert.Equal(MathBlockValueKind.Vector, vector.Kind);
        Assert.Equal(MathBlockUnit.Basis2, vector.Unit);
        Assert.Equal(MathBlockValueKind.BooleanVector, flags.Kind);
        Assert.Equal(MathBlockUnit.Dimensionless, flags.Unit);
        Assert.Equal(MathBlockUnit.Dimensionless, plain.Unit);

        var add = MathBlockCatalog.Standard.Get("vector.add", 1);
        var output = new double[4];
        var refused = Assert.Throws<ArgumentException>(() => add.EvaluateCoreCLR(default, plain, output, MathBlockDomainOptions.Default));
        Assert.Equal("a", refused.ParamName);
        refused = Assert.Throws<ArgumentException>(() => add.EvaluateCoreCLR(plain, default, output, MathBlockDomainOptions.Default));
        Assert.Equal("b", refused.ParamName);
    }

    /// <summary>Verifies an argument count other than the arity, a missing option set, an invalid option set and a non-form for the per-row overload.</summary>
    [Fact]
    public void ArgumentChecksFollowTheEvaluationOnValues()
    {
        var add = MathBlockCatalog.Standard.Get("vector.add", 1);
        var contract = MathBlockCudaDeviceModule.GetOperation("vector.add@1");
        var square = MathBlockCatalog.Standard.Get("vector.square", 1);
        var one = new[] { 1d, 2d };
        var output = new double[4];
        var flags = new bool[4];

        var expected = Assert.Throws<ArgumentException>(() => add.Evaluate(MathBlockValue.Vector(one)));
        var oneArgument = Assert.Throws<ArgumentException>(() => add.EvaluateCoreCLR(MathBlockSpanArgument.Vector(one), output, MathBlockDomainOptions.Default));
        Assert.Equal(expected.Message, oneArgument.Message);
        var threeArguments = Assert.Throws<ArgumentException>(() => square.EvaluateCoreCLR(
            MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Vector(one), output, MathBlockDomainOptions.Default));
        Assert.Contains("requires 1 inputs, but received 3", threeArguments.Message, StringComparison.Ordinal);
        Assert.Throws<ArgumentNullException>(() => add.EvaluateCoreCLR(MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Vector(one), output, null!));
        Assert.Throws<ArgumentNullException>(() => contract.EvaluateCoreCLR(MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Vector(one), output, null!));
        Assert.Throws<ArgumentOutOfRangeException>(() => add.EvaluateCoreCLR(
            MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Vector(one), output, new MathBlockDomainOptions { MaximumGeneratedVectorLength = 0 }));
        Assert.Throws<InvalidOperationException>(() => add.EvaluateCoreCLR(
            MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Scalar(0d), output, flags, MathBlockDomainOptions.Default));
        Assert.Throws<InvalidOperationException>(() => contract.EvaluateCoreCLR(
            MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Vector(one), MathBlockSpanArgument.Scalar(0d), output, flags, MathBlockDomainOptions.Default));
    }

    /// <summary>Verifies the generated-vector limit of the domain options decides vector.repeat the way the evaluation on values does.</summary>
    [Fact]
    public void RepeatFollowsTheGeneratedVectorLimit()
    {
        var repeat = MathBlockCatalog.Standard.Get("vector.repeat", 1);
        var options = new MathBlockDomainOptions { MaximumGeneratedVectorLength = 10 };
        var output = new double[16];

        foreach (var count in new[] { 0d, 1d, 10d, 11d, -1d, 2.5d, 1e300d })
        {
            var expected = repeat.Evaluate(new[] { MathBlockValue.Scalar(1.25d), MathBlockValue.Scalar(count) }, options);
            var actual = repeat.EvaluateCoreCLR(MathBlockSpanArgument.Scalar(1.25d), MathBlockSpanArgument.Scalar(count), output, options);
            Assert.Equal(expected.IsValid, actual.IsValid);
            if (!expected.IsValid)
                continue;
            Assert.Equal(expected.AsVector().Count, actual.Rows);
            for (var row = 0; row < actual.Rows; row++)
                Assert.Equal(1.25d, output[row]);
        }
    }

    private static IEnumerable<string> ElementwiseIdentifiers()
    {
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            var identifier = operation.Identifier;
            var form = identifier.StartsWith(ElementwiseFormPrefix, StringComparison.Ordinal);
            var validity = identifier.StartsWith(ElementwiseValidityPrefix, StringComparison.Ordinal);
            if ((form || validity) && operation.Arity <= 3)
                yield return identifier;
        }
    }

    // A seed that does not change from one process to the next, so a failing case repeats.
    private static int SeedOf(string identifier, int salt)
    {
        var seed = salt;
        foreach (var character in identifier)
            seed = unchecked((seed * 31) + character);
        return seed;
    }

    private static string SourceOf(string identifier) =>
        identifier.StartsWith(ElementwiseFormPrefix, StringComparison.Ordinal)
            ? identifier[ElementwiseFormPrefix.Length..]
            : identifier[ElementwiseValidityPrefix.Length..];

    private static bool IsForm(string identifier) => identifier.StartsWith(ElementwiseFormPrefix, StringComparison.Ordinal);

    private static string[] ShapesOf(string identifier)
    {
        if (CoveredShapes.TryGetValue(identifier, out var covered))
            return covered;
        if (FallbackShapes.TryGetValue(identifier, out var fallback))
            return fallback;
        var arity = MathBlockCatalog.Standard.Get(identifier, 1).Arity;
        if (IsForm(identifier))
            return arity == 2 ? ["VS"] : ["VVS", "VSS", "SVS"];
        return arity switch
        {
            1 => ["V"],
            2 => ["VV", "VS", "SV"],
            _ => ["VVV"]
        };
    }

    private static IEnumerable<(string Label, Operand[] Operands)> Cases(MathBlockOperation operation, string shape, Random random)
    {
        foreach (var regression in operation.RegressionCases)
        {
            var converted = new List<Operand>();
            foreach (var input in regression.Inputs)
            {
                if (Operand.TryFrom(input, out var operand))
                    converted.Add(operand);
            }

            if (converted.Count == regression.Inputs.Count)
                yield return ("regression " + regression.Name, converted.ToArray());
        }

        foreach (var length in Lengths)
        {
            yield return ("random " + length.ToString(CultureInfo.InvariantCulture), Build(shape, length, random, positive: false));
            yield return ("positive " + length.ToString(CultureInfo.InvariantCulture), Build(shape, length, random, positive: true));
        }

        yield return ("edge values", BuildEdge(shape, 17));
        yield return ("edge values, one row", BuildEdge(shape, 1));
        var basis = Build(shape, 17, random, positive: true);
        for (var index = 0; index < basis.Length; index++)
        {
            if (basis[index].Kind == MathBlockValueKind.BooleanVector)
                continue;
            foreach (var bad in BadValues)
            {
                var poisoned = (Operand[])basis.Clone();
                poisoned[index] = basis[index].WithBadElement(bad);
                yield return ("nonfinite " + bad.ToString(CultureInfo.InvariantCulture) + " in argument " + index.ToString(CultureInfo.InvariantCulture), poisoned);
            }
        }

        var vectors = 0;
        for (var index = 0; index < basis.Length; index++)
        {
            if (basis[index].Kind is MathBlockValueKind.Vector or MathBlockValueKind.BooleanVector && ++vectors == 2)
            {
                var uneven = (Operand[])basis.Clone();
                uneven[index] = basis[index].Shortened();
                yield return ("unequal lengths", uneven);
            }
        }

        var united = new Operand[basis.Length];
        var mixed = new Operand[basis.Length];
        for (var index = 0; index < basis.Length; index++)
        {
            united[index] = basis[index].WithUnit(MathBlockUnit.Basis0);
            mixed[index] = index == 0 ? united[index] : basis[index];
        }

        yield return ("one unit on every argument", united);
        yield return ("a unit on the first argument", mixed);
        var wrong = (Operand[])basis.Clone();
        wrong[0] = basis[0].OtherKind();
        yield return ("another kind in the first argument", wrong);
        var last = (Operand[])basis.Clone();
        last[^1] = basis[^1].OtherKind();
        yield return ("another kind in the last argument", last);
    }

    private static Operand[] Build(string shape, int length, Random random, bool positive)
    {
        var operands = new Operand[shape.Length];
        for (var index = 0; index < shape.Length; index++)
        {
            switch (shape[index])
            {
                case 'V':
                    var values = new double[length];
                    for (var row = 0; row < length; row++)
                        values[row] = positive ? 0.001d + (random.NextDouble() * 50d) : (random.NextDouble() * 200d) - 100d;
                    operands[index] = Operand.OfVector(values);
                    break;
                case 'S':
                    operands[index] = Operand.OfScalar(ScalarPool[random.Next(ScalarPool.Length)]);
                    break;
                default:
                    var flags = new bool[length];
                    for (var row = 0; row < length; row++)
                        flags[row] = random.Next(2) == 0;
                    operands[index] = Operand.OfFlags(flags);
                    break;
            }
        }

        return operands;
    }

    private static Operand[] BuildEdge(string shape, int length)
    {
        var operands = new Operand[shape.Length];
        for (var index = 0; index < shape.Length; index++)
        {
            switch (shape[index])
            {
                case 'V':
                    var values = new double[length];
                    for (var row = 0; row < length; row++)
                        values[row] = EdgeValues[(row + (index * 5)) % EdgeValues.Length];
                    operands[index] = Operand.OfVector(values);
                    break;
                case 'S':
                    operands[index] = Operand.OfScalar(EdgeValues[(index * 3) % EdgeValues.Length]);
                    break;
                default:
                    var flags = new bool[length];
                    for (var row = 0; row < length; row++)
                        flags[row] = ((row + index) % 3) != 0;
                    operands[index] = Operand.OfFlags(flags);
                    break;
            }
        }

        return operands;
    }

    // Arguments with finite results for every operation of the lists: positive vectors, the scalar 2 and the count of vector.repeat as the length.
    private static Operand[] Benign(string identifier, string shape, int length)
    {
        if (string.Equals(identifier, "vector.repeat", StringComparison.Ordinal))
            return [Operand.OfScalar(2.5d), Operand.OfScalar(length)];
        var operands = new Operand[shape.Length];
        for (var index = 0; index < shape.Length; index++)
        {
            switch (shape[index])
            {
                case 'V':
                    var values = new double[length];
                    for (var row = 0; row < length; row++)
                        values[row] = 0.5d + (0.25d * ((row * 7 + index) % 13));
                    operands[index] = Operand.OfVector(values);
                    break;
                case 'S':
                    operands[index] = Operand.OfScalar(index == shape.Length - 1 && IsForm(identifier) ? -1d : 2d);
                    break;
                default:
                    var flags = new bool[length];
                    for (var row = 0; row < length; row++)
                        flags[row] = ((row + index) % 2) == 0;
                    operands[index] = Operand.OfFlags(flags);
                    break;
            }
        }

        return operands;
    }

    private static MathBlockValue[] ValuesOf(Operand[] operands)
    {
        var values = new MathBlockValue[operands.Length];
        for (var index = 0; index < operands.Length; index++)
            values[index] = operands[index].ToValue();
        return values;
    }

    private static string? Capture(Func<MathBlockValue> evaluation, out MathBlockValue value)
    {
        value = default;
        try
        {
            value = evaluation();
            return null;
        }
        catch (Exception exception) when (exception is InvalidOperationException or ArgumentException)
        {
            return exception.GetType().FullName + ": " + exception.Message;
        }
    }

    private static string? Capture(Func<MathBlockEvaluation> evaluation, out MathBlockEvaluation result)
    {
        result = default;
        try
        {
            result = evaluation();
            return null;
        }
        catch (Exception exception) when (exception is InvalidOperationException or ArgumentException)
        {
            return exception.GetType().FullName + ": " + exception.Message;
        }
    }

    private static MathBlockEvaluation Run(MathBlockOperation operation, Operand[] operands, Span<double> output) => operands.Length switch
    {
        1 => operation.EvaluateCoreCLR(operands[0].Argument(), output, MathBlockDomainOptions.Default),
        2 => operation.EvaluateCoreCLR(operands[0].Argument(), operands[1].Argument(), output, MathBlockDomainOptions.Default),
        _ => operation.EvaluateCoreCLR(operands[0].Argument(), operands[1].Argument(), operands[2].Argument(), output, MathBlockDomainOptions.Default)
    };

    private static MathBlockEvaluation Run(MathBlockCudaOperationContract contract, Operand[] operands, Span<double> output) => operands.Length switch
    {
        1 => contract.EvaluateCoreCLR(operands[0].Argument(), output, MathBlockDomainOptions.Default),
        2 => contract.EvaluateCoreCLR(operands[0].Argument(), operands[1].Argument(), output, MathBlockDomainOptions.Default),
        _ => contract.EvaluateCoreCLR(operands[0].Argument(), operands[1].Argument(), operands[2].Argument(), output, MathBlockDomainOptions.Default)
    };

    private static MathBlockEvaluation RunRows(MathBlockOperation operation, Operand[] operands, Span<double> output, Span<bool> rowValid) => operands.Length switch
    {
        1 => operation.EvaluateCoreCLR(operands[0].Argument(), output, rowValid, MathBlockDomainOptions.Default),
        2 => operation.EvaluateCoreCLR(operands[0].Argument(), operands[1].Argument(), output, rowValid, MathBlockDomainOptions.Default),
        _ => operation.EvaluateCoreCLR(operands[0].Argument(), operands[1].Argument(), operands[2].Argument(), output, rowValid, MathBlockDomainOptions.Default)
    };

    private static MathBlockEvaluation RunRows(MathBlockCudaOperationContract contract, Operand[] operands, Span<double> output, Span<bool> rowValid) => operands.Length switch
    {
        1 => contract.EvaluateCoreCLR(operands[0].Argument(), output, rowValid, MathBlockDomainOptions.Default),
        2 => contract.EvaluateCoreCLR(operands[0].Argument(), operands[1].Argument(), output, rowValid, MathBlockDomainOptions.Default),
        _ => contract.EvaluateCoreCLR(operands[0].Argument(), operands[1].Argument(), operands[2].Argument(), output, rowValid, MathBlockDomainOptions.Default)
    };

    // Three warm calls, then one whose allocation is measured; the argument is built inside the measured call, as a caller builds it.
    private static long MeasureAllocation(MathBlockOperation operation, Operand[] operands, double[] output)
    {
        Run(operation, operands, output);
        Run(operation, operands, output);
        Run(operation, operands, output);
        var before = GC.GetAllocatedBytesForCurrentThread();
        Run(operation, operands, output);
        return GC.GetAllocatedBytesForCurrentThread() - before;
    }

    private static long MeasureAllocation(MathBlockCudaOperationContract contract, Operand[] operands, double[] output)
    {
        Run(contract, operands, output);
        Run(contract, operands, output);
        Run(contract, operands, output);
        var before = GC.GetAllocatedBytesForCurrentThread();
        Run(contract, operands, output);
        return GC.GetAllocatedBytesForCurrentThread() - before;
    }

    private static long MeasureAllocation(MathBlockOperation operation, Operand[] operands, double[] output, bool[] rowValid)
    {
        RunRows(operation, operands, output, rowValid);
        RunRows(operation, operands, output, rowValid);
        RunRows(operation, operands, output, rowValid);
        var before = GC.GetAllocatedBytesForCurrentThread();
        RunRows(operation, operands, output, rowValid);
        return GC.GetAllocatedBytesForCurrentThread() - before;
    }

    private static long MeasureAllocation(MathBlockCudaOperationContract contract, Operand[] operands, double[] output, bool[] rowValid)
    {
        RunRows(contract, operands, output, rowValid);
        RunRows(contract, operands, output, rowValid);
        RunRows(contract, operands, output, rowValid);
        var before = GC.GetAllocatedBytesForCurrentThread();
        RunRows(contract, operands, output, rowValid);
        return GC.GetAllocatedBytesForCurrentThread() - before;
    }

    private static void AssertEqualsEvaluation(MathBlockOperation operation, MathBlockCudaOperationContract contract, Operand[] operands, string label)
    {
        var values = ValuesOf(operands);
        var expectedError = Capture(() => operation.Evaluate(values), out var expected);
        var output = new double[OutputSize];

        var actualError = Capture(() => Run(operation, operands, output), out var actual);
        Assert.True(string.Equals(expectedError, actualError, StringComparison.Ordinal), label + ": " + expectedError + " <> " + actualError);
        if (expectedError is not null)
        {
            var viaContract = Capture(() => Run(contract, operands, output), out _);
            Assert.True(string.Equals(expectedError, viaContract, StringComparison.Ordinal), label + " (contract): " + expectedError + " <> " + viaContract);
            var viaValues = Capture(() => contract.EvaluateCoreCLR(values, output, MathBlockDomainOptions.Default), out _);
            Assert.True(string.Equals(expectedError, viaValues, StringComparison.Ordinal), label + " (values): " + expectedError + " <> " + viaValues);
            return;
        }

        AssertSameRows(expected, actual, output, label);
        var contractOutput = new double[OutputSize];
        AssertSameRows(expected, Run(contract, operands, contractOutput), contractOutput, label + " (contract)");
        var valuesOutput = new double[OutputSize];
        AssertSameRows(expected, contract.EvaluateCoreCLR(values, valuesOutput, MathBlockDomainOptions.Default), valuesOutput, label + " (values)");
    }

    private static void AssertSameRows(MathBlockValue expected, MathBlockEvaluation actual, double[] output, string label)
    {
        Assert.True(expected.IsValid == actual.IsValid, label + ": validity");
        if (!expected.IsValid)
        {
            Assert.True(expected.Type.Rows == actual.Rows, label + ": rows of an invalid result");
            return;
        }

        if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
        {
            var flags = expected.AsBooleanVector();
            Assert.True(flags.Count == actual.Rows, label + ": rows");
            for (var row = 0; row < flags.Count; row++)
            {
                if ((flags[row] ? 1d : 0d) != output[row])
                    Assert.Fail(label + ": flag " + row.ToString(CultureInfo.InvariantCulture) + " differs");
            }

            return;
        }

        var vector = expected.AsVector();
        Assert.True(vector.Count == actual.Rows, label + ": rows");
        for (var row = 0; row < vector.Count; row++)
        {
            if (BitConverter.DoubleToInt64Bits(vector[row]) != BitConverter.DoubleToInt64Bits(output[row]))
                Assert.Fail(label + ": row " + row.ToString(CultureInfo.InvariantCulture) + " differs in its bits");
        }
    }

    private static void AssertRowsEqualFormAndSibling(
        MathBlockOperation form,
        MathBlockCudaOperationContract contract,
        MathBlockOperation sibling,
        Operand[] operands,
        string label)
    {
        var values = ValuesOf(operands);
        var formError = Capture(() => form.Evaluate(values), out var expected);
        var siblingError = formError is null
            ? Capture(() => sibling.Evaluate(values[..^1]), out _)
            : null;
        var output = new double[OutputSize];
        var rowValid = new bool[OutputSize];

        var actualError = Capture(() => RunRows(form, operands, output, rowValid), out var actual);
        if (formError is not null)
        {
            Assert.True(string.Equals(formError, actualError, StringComparison.Ordinal), label + ": " + formError + " <> " + actualError);
            return;
        }

        Assert.Null(actualError);
        Assert.Null(siblingError);
        if (!expected.IsValid)
        {
            Assert.False(actual.IsValid, label + ": validity");
            Assert.True(expected.Type.Rows == actual.Rows, label + ": rows of an invalid result");
            return;
        }

        var expectedFlags = sibling.Evaluate(values[..^1]).AsBooleanVector();
        Assert.True(actual.IsValid && actual.Rows == expectedFlags.Count, label + ": rows");
        AssertSameRows(expected, actual, output, label);
        for (var row = 0; row < expectedFlags.Count; row++)
        {
            if (expectedFlags[row] != rowValid[row])
                Assert.Fail(label + ": validity of row " + row.ToString(CultureInfo.InvariantCulture) + " differs");
        }

        var contractOutput = new double[OutputSize];
        var contractValid = new bool[OutputSize];
        var viaContract = RunRows(contract, operands, contractOutput, contractValid);
        AssertSameRows(expected, viaContract, contractOutput, label + " (contract)");
        for (var row = 0; row < expectedFlags.Count; row++)
        {
            if (expectedFlags[row] != contractValid[row])
                Assert.Fail(label + " (contract): validity of row " + row.ToString(CultureInfo.InvariantCulture) + " differs");
        }
    }

    // One argument as data: the kind with its numbers and unit, which gives the span argument and the value that hold the same numbers.
    private sealed class Operand
    {
        private Operand(MathBlockValueKind kind, MathBlockUnit unit, double scalar, double[] values, bool[] flags)
        {
            Kind = kind;
            Unit = unit;
            Scalar = scalar;
            Values = values;
            Flags = flags;
        }

        internal MathBlockValueKind Kind { get; }

        internal MathBlockUnit Unit { get; }

        internal double Scalar { get; }

        internal double[] Values { get; }

        internal bool[] Flags { get; }

        internal static Operand OfScalar(double value, MathBlockUnit unit = default) => new(MathBlockValueKind.Scalar, unit, value, [], []);

        internal static Operand OfVector(double[] values, MathBlockUnit unit = default) => new(MathBlockValueKind.Vector, unit, 0d, values, []);

        internal static Operand OfFlags(bool[] flags) => new(MathBlockValueKind.BooleanVector, MathBlockUnit.Dimensionless, 0d, [], flags);

        internal static bool TryFrom(MathBlockValue value, out Operand operand)
        {
            operand = OfScalar(0d);
            switch (value.Type.Kind)
            {
                case MathBlockValueKind.Scalar:
                    operand = OfScalar(value.AsScalar(), value.Type.Unit);
                    return true;
                case MathBlockValueKind.Vector:
                    operand = OfVector(value.AsVector().ToArray(), value.Type.Unit);
                    return true;
                case MathBlockValueKind.BooleanVector:
                    operand = OfFlags(value.AsBooleanVector().ToArray());
                    return true;
                default:
                    return false;
            }
        }

        internal MathBlockSpanArgument Argument() => Kind switch
        {
            MathBlockValueKind.Scalar => MathBlockSpanArgument.Scalar(Scalar, Unit),
            MathBlockValueKind.Vector => MathBlockSpanArgument.Vector(Values, Unit),
            _ => MathBlockSpanArgument.BooleanVector(Flags)
        };

        // The value that holds these numbers; a vector with a nonfinite element is the invalid value of its type, as the evaluation on values has it.
        internal MathBlockValue ToValue()
        {
            switch (Kind)
            {
                case MathBlockValueKind.Scalar:
                    return MathBlockValue.Scalar(Scalar, Unit);
                case MathBlockValueKind.Vector:
                    return Array.TrueForAll(Values, double.IsFinite)
                        ? MathBlockValue.Vector(Values, Unit)
                        : MathBlockValue.Invalid(MathBlockType.Vector(Unit, Values.Length), "The vector result contains a nonfinite value.");
                default:
                    return MathBlockValue.BooleanVector(Flags);
            }
        }

        internal Operand WithUnit(MathBlockUnit unit) => Kind switch
        {
            MathBlockValueKind.Scalar => OfScalar(Scalar, unit),
            MathBlockValueKind.Vector => OfVector(Values, unit),
            _ => this
        };

        internal Operand WithBadElement(double bad)
        {
            if (Kind == MathBlockValueKind.Scalar)
                return OfScalar(bad, Unit);
            var copy = (double[])Values.Clone();
            copy[Math.Min(3, copy.Length - 1)] = bad;
            return OfVector(copy, Unit);
        }

        internal Operand Shortened() => Kind == MathBlockValueKind.Vector
            ? OfVector(Values[..^1], Unit)
            : OfFlags(Flags[..^1]);

        internal Operand OtherKind() => Kind == MathBlockValueKind.Vector
            ? OfScalar(1.5d, Unit)
            : OfVector([1d, 2d, 3d]);
    }
}
