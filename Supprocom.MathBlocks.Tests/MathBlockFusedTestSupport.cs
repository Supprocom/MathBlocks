using System.Reflection;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

// Random pointwise programs and inputs for the fused-expression tests, and bit-exact comparison of values.
internal static class MathBlockFusedTestSupport
{
    public const int FullRows = 302_893;

    // The fused row forms: identity, argument kinds and result kind. N is a Vector row, S a scalar, B a
    // BooleanVector row and C a ComplexVector row.
    public static readonly (string Identity, string Arguments, char Result)[] Operations =
    [
        ("vector.absolute", "N", 'N'), ("vector.add-scalar", "NS", 'N'), ("vector.add", "NN", 'N'),
        ("vector.subtract", "NN", 'N'), ("vector.multiply", "NN", 'N'), ("vector.divide", "NN", 'N'),
        ("vector.scale", "NS", 'N'), ("vector.sign", "N", 'N'), ("vector.positive-part", "N", 'N'),
        ("vector.square", "N", 'N'), ("vector.square-root", "N", 'N'), ("vector.exponential", "N", 'N'),
        ("vector.natural-logarithm", "N", 'N'), ("vector.power", "NS", 'N'), ("vector.equal", "NN", 'B'),
        ("vector.less-than", "NN", 'B'), ("vector.greater-than", "NN", 'B'), ("vector.select", "BNN", 'N'),
        ("boolean-vector.and", "BB", 'B'), ("boolean-vector.or", "BB", 'B'), ("boolean-vector.xor", "BB", 'B'),
        ("boolean-vector.not", "B", 'B'), ("complex-vector.create", "NN", 'C'), ("complex-vector.real", "C", 'N'),
        ("complex-vector.imaginary", "C", 'N'), ("complex-vector.magnitude", "C", 'N')
    ];

    // Adversarial values: signed zeros, subnormals, the edges of exp and log, huge values that overflow under
    // add, multiply and square, and exact ties.
    public static readonly double[] AdversarialValues =
    [
        0d, -0d, double.Epsilon, -double.Epsilon, 2.2250738585072014e-308, -2.2250738585072014e-308,
        1e-310, -1e-310, 1d, -1d, 0.5, 2d, 709.782712893384, 709.79, -745.13, -745.2, 1e154, 1.4e154,
        1e300, -1e300, double.MaxValue, -double.MaxValue, 3d, -8d, 1e-300, 4.9e-324 * 3
    ];

    public enum Regime
    {
        Benign,
        Signed,
        Adversarial
    }

    public static MathBlockProgram CreateRandomProgram(
        Random random,
        int vectorInputs,
        int booleanInputs,
        int scalarInputs,
        int operations,
        int outputs)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var byKind = new Dictionary<char, List<int>>
        {
            ['N'] = [],
            ['S'] = [],
            ['B'] = [],
            ['C'] = []
        };
        for (var index = 0; index < vectorInputs; index++)
            byKind['N'].Add(builder.Input($"x{index}", MathBlockType.Vector()));
        for (var index = 0; index < booleanInputs; index++)
            byKind['B'].Add(builder.Input($"m{index}", MathBlockType.BooleanVector()));
        for (var index = 0; index < scalarInputs; index++)
            byKind['S'].Add(builder.Input($"s{index}", MathBlockType.Scalar()));
        byKind['S'].Add(builder.Constant(MathBlockValue.Scalar(PickScalar(random))));

        var created = new List<(int Node, char Kind)>();
        while (created.Count < operations)
        {
            var (identity, arguments, result) = Operations[random.Next(Operations.Length)];
            if (arguments.Any(kind => byKind[kind].Count == 0))
                continue;
            var inputs = arguments.Select(kind => PickNode(random, byKind[kind])).ToArray();
            var node = builder.Apply(identity, 1, inputs);
            byKind[result].Add(node);
            created.Add((node, result));
        }

        var candidates = created.Where(item => item.Kind is 'N' or 'B').Select(item => item.Node).ToList();
        if (candidates.Count == 0)
            candidates.AddRange(byKind['N']);
        var chosen = new List<int>();
        for (var index = candidates.Count - 1; index >= 0 && chosen.Count < outputs; index--)
            if (chosen.Count == 0 || random.Next(3) != 0)
                chosen.Add(candidates[index]);
        for (var index = 0; index < chosen.Count; index++)
            builder.Output($"y{index}", chosen[index]);
        return builder.Build();
    }

    public static Dictionary<string, MathBlockValue> CreateInputs(
        MathBlockProgram program,
        int rows,
        Regime regime,
        Random random)
    {
        var pool = Enumerable.Range(0, 8).Select(_ => PickValue(random, regime)).ToArray();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal);
        foreach (var (name, type) in program.Inputs.OrderBy(pair => pair.Key, StringComparer.Ordinal))
        {
            switch (type.Kind)
            {
                case MathBlockValueKind.Vector:
                    var values = new double[rows];
                    for (var row = 0; row < rows; row++)
                        values[row] = random.Next(4) == 0 ? pool[random.Next(pool.Length)] : PickValue(random, regime);
                    inputs[name] = MathBlockValue.Vector(values);
                    break;
                case MathBlockValueKind.BooleanVector:
                    var flags = new bool[rows];
                    for (var row = 0; row < rows; row++)
                        flags[row] = random.Next(2) == 0;
                    inputs[name] = MathBlockValue.BooleanVector(flags);
                    break;
                default:
                    inputs[name] = MathBlockValue.Scalar(PickScalar(random));
                    break;
            }
        }
        return inputs;
    }

    // Random validity inputs for about half of the vector inputs, true in about four rows of five.
    public static Dictionary<string, MathBlockValue> CreateValidity(MathBlockProgram program, int rows, Random random)
    {
        var validity = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal);
        foreach (var (name, type) in program.Inputs.OrderBy(pair => pair.Key, StringComparer.Ordinal))
        {
            if (type.Kind == MathBlockValueKind.Scalar || random.Next(2) == 0)
                continue;
            var flags = new bool[rows];
            for (var row = 0; row < rows; row++)
                flags[row] = random.Next(5) != 0;
            validity[name] = MathBlockValue.BooleanVector(flags);
        }
        return validity;
    }

    // The unfused reference for an output's row validity: the boolean-vector.and@1 combination of the validity
    // inputs of the vector inputs that reach the output, in input node order.
    public static MathBlockValue CombineValidity(
        MathBlockProgram program,
        string output,
        IReadOnlyDictionary<string, MathBlockValue> validity,
        int rows)
    {
        var reached = new SortedSet<int>();
        var pending = new Stack<int>();
        pending.Push(program.OutputNodeIndexes[output]);
        while (pending.Count > 0)
        {
            var node = program.PlanNodes[pending.Pop()];
            if (node.Kind == MathBlockProgramNodeKind.Input && node.Type.Kind != MathBlockValueKind.Scalar)
                reached.Add(node.Index);
            foreach (var input in node.Inputs)
                pending.Push(input);
        }

        var and = MathBlockCatalog.Standard.Get("boolean-vector.and");
        MathBlockValue? combined = null;
        foreach (var node in reached)
        {
            if (!validity.TryGetValue(program.PlanNodes[node].Name!, out var value))
                continue;
            combined = combined is { } previous ? and.Evaluate(previous, value) : value;
        }
        return combined ?? MathBlockValue.BooleanVector(new bool[rows].Select(_ => true));
    }

    public static void AssertSameValue(MathBlockValue expected, MathBlockValue actual, string context)
    {
        Assert.True(expected.Type == actual.Type, $"{context}: type {actual.Type}, expected {expected.Type}.");
        Assert.True(
            expected.IsValid == actual.IsValid,
            $"{context}: valid {actual.IsValid} ({actual.InvalidReason}), expected {expected.IsValid} ({expected.InvalidReason}).");
        Assert.True(
            string.Equals(expected.InvalidReason, actual.InvalidReason, StringComparison.Ordinal),
            $"{context}: reason '{actual.InvalidReason}', expected '{expected.InvalidReason}'.");
        if (expected.IsValid)
            AssertSamePayload(expected, actual, context);
    }

    public static void AssertSamePayload(MathBlockValue expected, MathBlockValue actual, string context)
    {
        if (expected.Type.Kind == MathBlockValueKind.Vector)
        {
            var left = expected.AsVector();
            var right = actual.AsVector();
            Assert.True(left.Count == right.Count, $"{context}: {right.Count} rows, expected {left.Count}.");
            for (var row = 0; row < left.Count; row++)
                if (BitConverter.DoubleToUInt64Bits(left[row]) != BitConverter.DoubleToUInt64Bits(right[row]))
                    Assert.Fail($"{context} row {row}: {right[row]:R} (0x{BitConverter.DoubleToUInt64Bits(right[row]):x16}), expected {left[row]:R} (0x{BitConverter.DoubleToUInt64Bits(left[row]):x16}).");
        }
        else
        {
            var left = expected.AsBooleanVector();
            var right = actual.AsBooleanVector();
            Assert.True(left.Count == right.Count, $"{context}: {right.Count} rows, expected {left.Count}.");
            for (var row = 0; row < left.Count; row++)
                if (left[row] != right[row])
                    Assert.Fail($"{context} row {row}: {right[row]}, expected {left[row]}.");
        }
    }

    // Checks a fused result against the unfused program and the and@1 combination of the validity inputs.
    public static void AssertMatchesUnfused(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue> inputs,
        IReadOnlyDictionary<string, MathBlockValue> validity,
        MathBlockFusedResult result,
        string context)
    {
        var expected = program.Evaluate(inputs);
        var rows = inputs.Values.Where(value => value.IsValid && value.Type.Kind is MathBlockValueKind.Vector or
                MathBlockValueKind.BooleanVector)
            .Select(value => value.Type.Kind == MathBlockValueKind.Vector
                ? value.AsVector().Count
                : value.AsBooleanVector().Count)
            .FirstOrDefault();
        Assert.Equal(expected.Count, result.Outputs.Count);
        foreach (var (name, value) in expected)
        {
            AssertSameValue(value, result.Outputs[name], $"{context} output {name}");
            AssertSameValue(
                CombineValidity(program, name, validity, rows),
                result.Validity[name],
                $"{context} validity {name}");
        }
    }

    public static MathBlockFusedResult[] RunCuda(
        string consumerSource,
        bool fusedMultiplyAdd,
        IReadOnlyList<MathBlockFusedExpression> expressions,
        IReadOnlyList<IReadOnlyDictionary<string, MathBlockValue>> inputs,
        IReadOnlyList<IReadOnlyDictionary<string, MathBlockValue>?> validity)
    {
        var runner = typeof(MathBlocksCUDAWorker).Assembly.GetType(
            "Supprocom.MathBlocks.Cuda.MathBlockFusedCudaRunner",
            throwOnError: true)!;
        var run = runner.GetMethod("Run", BindingFlags.Public | BindingFlags.Static)!;
        try
        {
            return (MathBlockFusedResult[])run.Invoke(
                null,
                [consumerSource, fusedMultiplyAdd, expressions, inputs, validity])!;
        }
        catch (TargetInvocationException exception) when (exception.InnerException is not null)
        {
            throw exception.InnerException;
        }
    }

    private static int PickNode(Random random, List<int> nodes) =>
        random.Next(3) == 0 ? nodes[random.Next(nodes.Count)] : nodes[Math.Max(0, nodes.Count - 1 - random.Next(3))];

    private static double PickScalar(Random random) =>
        new[] { 2d, 0.5, -1d, 3d, 0d, -0d, 1e-310, 2.5, 1d / 3d, -0.75 }[random.Next(10)];

    private static double PickValue(Random random, Regime regime) => regime switch
    {
        Regime.Benign => 0.5 + random.NextDouble() * 1.5,
        Regime.Signed => random.Next(6) switch
        {
            0 => random.Next(2) == 0 ? 0d : -0d,
            1 => (random.Next(2) == 0 ? 1 : -1) * double.Epsilon * random.Next(1, 1000),
            2 => (random.Next(2) == 0 ? 1 : -1) * 2.2250738585072014e-308 * random.NextDouble(),
            _ => random.NextDouble() * 6d - 3d
        },
        _ => random.Next(3) == 0
            ? AdversarialValues[random.Next(AdversarialValues.Length)]
            : random.NextDouble() * 4d - 2d
    };
}
