using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains tests for the non-allocating span evaluation and the scalar-to-vector twin lookup.</summary>
public sealed class MathBlockSpanEvaluationTests
{
    private static readonly double[] Left = [-2.5d, -1.5d, -0.5d, -0d, 0d, 0.5d, 1.5d, 2.5d, 1e300d, -1e300d, 9007199254740993d, 5e-324d];
    private static readonly double[] Right = [3d, -3d, 0.5d, 2d, -0d, 7d, -7d, 0d, 1e-300d, 1e300d, 3d, -5e-324d];
    private static readonly bool[] FlagsA = [true, false, true, false, true, false, true, false, true, false, true, false];
    private static readonly bool[] FlagsB = [true, true, false, false, true, true, false, false, true, true, false, false];

    /// <summary>Lists the 19 operations of the generic mathematical set with their vector forms.</summary>
    public static TheoryData<string> PatternOperations => new()
    {
        "vector.absolute@1", "elementwise.scalar.negate@1", "elementwise.scalar.floor@1", "elementwise.scalar.round@1",
        "vector.add@1", "vector.subtract@1", "vector.multiply@1", "vector.divide@1", "elementwise.scalar.modulo@1",
        "elementwise.scalar.minimum@1", "elementwise.scalar.maximum@1", "vector.greater-than@1", "vector.less-than@1",
        "vector.equal@1", "boolean-vector.and@1", "boolean-vector.or@1", "boolean-vector.xor@1", "boolean-vector.not@1",
        "vector.select@1"
    };

    /// <summary>Verifies each scalar operation of the set has a vector twin, with the arity and the public family and opcode.</summary>
    [Fact]
    public void EveryScalarOperationHasAVectorTwin()
    {
        var expected = new Dictionary<string, (string Twin, int Arity)>(StringComparer.Ordinal)
        {
            ["scalar.absolute@1"] = ("vector.absolute@1", 1),
            ["scalar.add@1"] = ("vector.add@1", 2),
            ["scalar.subtract@1"] = ("vector.subtract@1", 2),
            ["scalar.multiply@1"] = ("vector.multiply@1", 2),
            ["scalar.divide@1"] = ("vector.divide@1", 2),
            ["scalar.negate@1"] = ("elementwise.scalar.negate@1", 2),
            ["scalar.floor@1"] = ("elementwise.scalar.floor@1", 2),
            ["scalar.round@1"] = ("elementwise.scalar.round@1", 2),
            ["scalar.modulo@1"] = ("elementwise.scalar.modulo@1", 3),
            ["scalar.minimum@1"] = ("elementwise.scalar.minimum@1", 3),
            ["scalar.maximum@1"] = ("elementwise.scalar.maximum@1", 3)
        };

        Assert.Equal(11, expected.Count);
        foreach (var (scalar, (twin, arity)) in expected)
        {
            Assert.True(MathBlockCatalog.TryGetVectorTwin(scalar, out var found), scalar);
            Assert.Equal(twin, found);
            var contract = MathBlockCudaDeviceModule.GetOperation(found);
            Assert.Equal(arity, contract.Arity);
            Assert.True(Enum.IsDefined(contract.Family));
            Assert.True(contract.Opcode >= 0);
            var scalarArity = MathBlockCudaDeviceModule.GetOperation(scalar).Arity;
            Assert.Equal(found.StartsWith("elementwise.", StringComparison.Ordinal) ? scalarArity + 1 : scalarArity, contract.Arity);
        }

        Assert.False(MathBlockCatalog.TryGetVectorTwin("vector.add@1", out var none));
        Assert.Equal(string.Empty, none);
        Assert.False(MathBlockCatalog.TryGetVectorTwin("scalar.no-such@1", out _));
        Assert.Throws<ArgumentNullException>(() => MathBlockCatalog.TryGetVectorTwin(null!, out _));
    }

    /// <summary>Verifies the span evaluation allocates nothing on a warm call for the 19 operations.</summary>
    [Theory]
    [MemberData(nameof(PatternOperations))]
    public void SpanEvaluationDoesNotAllocate(string identity)
    {
        var contract = MathBlockCudaDeviceModule.GetOperation(identity);
        var inputs = CreateInputs(identity);
        var output = new double[Left.Length];
        contract.EvaluateCoreCLR(inputs, output, MathBlockDomainOptions.Default);
        contract.EvaluateCoreCLR(inputs, output, MathBlockDomainOptions.Default);

        var before = GC.GetAllocatedBytesForCurrentThread();
        var evaluation = contract.EvaluateCoreCLR(inputs, output, MathBlockDomainOptions.Default);
        var allocated = GC.GetAllocatedBytesForCurrentThread() - before;

        Assert.Equal(0L, allocated);
        Assert.Equal(0L, evaluation.NonConvergedCount);
    }

    /// <summary>Verifies the span evaluation equals the allocating evaluation bit for bit.</summary>
    [Theory]
    [MemberData(nameof(PatternOperations))]
    public void SpanEvaluationEqualsTheAllocatingEvaluation(string identity)
    {
        var contract = MathBlockCudaDeviceModule.GetOperation(identity);
        var inputs = CreateInputs(identity);
        var output = new double[Left.Length + 3];

        var evaluation = contract.EvaluateCoreCLR(inputs, output, MathBlockDomainOptions.Default);
        var expected = contract.EvaluateCoreCLR(inputs);

        Assert.Equal(expected.IsValid, evaluation.IsValid);
        if (!expected.IsValid)
            return;
        if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
        {
            var flags = expected.AsBooleanVector();
            Assert.Equal(flags.Count, evaluation.Rows);
            for (var index = 0; index < flags.Count; index++)
                Assert.Equal(flags[index] ? 1d : 0d, output[index]);
            return;
        }

        var vector = expected.AsVector();
        Assert.Equal(vector.Count, evaluation.Rows);
        for (var index = 0; index < vector.Count; index++)
            Assert.Equal(BitConverter.DoubleToInt64Bits(vector[index]), BitConverter.DoubleToInt64Bits(output[index]));
    }

    /// <summary>Verifies an invalid result, a short output and an operation without a span kernel.</summary>
    [Fact]
    public void InvalidResultsShortOutputsAndTheFallback()
    {
        var divide = MathBlockCudaDeviceModule.GetOperation("vector.divide@1");
        var zeroes = new[] { MathBlockValue.Vector([1d, 2d]), MathBlockValue.Vector([0d, 1d]) };
        var buffer = new double[2];

        Assert.False(divide.EvaluateCoreCLR(zeroes, buffer, MathBlockDomainOptions.Default).IsValid);
        var tooShort = Assert.Throws<ArgumentException>(() => divide.EvaluateCoreCLR(
            new[] { MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Vector([1d, 1d, 1d]) },
            buffer,
            MathBlockDomainOptions.Default));
        Assert.Contains("needs 3 elements", tooShort.Message, StringComparison.Ordinal);
        Assert.Equal("output", tooShort.ParamName);
        Assert.Throws<ArgumentNullException>(() => divide.EvaluateCoreCLR(zeroes, buffer, null!));

        var sort = MathBlockCudaDeviceModule.GetOperation("vector.sort@1");
        var unsorted = new[] { MathBlockValue.Vector([3d, 1d, 2d]) };
        var sortBuffer = new double[3];
        var sorted = sort.EvaluateCoreCLR(unsorted, sortBuffer, MathBlockDomainOptions.Default);

        Assert.True(sorted.IsValid);
        Assert.Equal(3, sorted.Rows);
        Assert.Equal([1d, 2d, 3d], sortBuffer);
        Assert.Throws<ArgumentException>(() => sort.EvaluateCoreCLR(unsorted, new double[1], MathBlockDomainOptions.Default));
    }

    /// <summary>Verifies the scalar operations that already have an elementwise form have it with one more argument.</summary>
    [Theory]
    [InlineData("negate")]
    [InlineData("floor")]
    [InlineData("round")]
    [InlineData("modulo")]
    [InlineData("minimum")]
    [InlineData("maximum")]
    public void ScalarOperationsWithAnElementwiseLiftHaveATwin(string name) => AssertElementwiseTwin(name);

    /// <summary>
    /// Verifies the five scalar operations whose elementwise lifts arrive with the merge of feat/0.7.0-limits have a twin.
    /// EXPECTED TO FAIL on this branch alone: absolute, add, subtract, multiply and divide have no elementwise lift
    /// here (worker D adds them as sources 41-52). It must pass after the merge; do not skip it.
    /// </summary>
    [Theory]
    [InlineData("absolute")]
    [InlineData("add")]
    [InlineData("subtract")]
    [InlineData("multiply")]
    [InlineData("divide")]
    public void ScalarOperationsWhoseLiftsComeWithTheMergeHaveATwin(string name) => AssertElementwiseTwin(name);

    private static void AssertElementwiseTwin(string name)
    {
        var scalar = $"scalar.{name}@1";
        Assert.True(MathBlockCatalog.TryGetElementwiseTwin(scalar, out var form), scalar);
        Assert.Equal($"elementwise.scalar.{name}@1", form);
        Assert.Equal(MathBlockCudaDeviceModule.GetOperation(scalar).Arity + 1, MathBlockCudaDeviceModule.GetOperation(form).Arity);
        Assert.False(MathBlockCatalog.TryGetElementwiseTwin("vector.add@1", out var none));
        Assert.Equal(string.Empty, none);
        Assert.False(MathBlockCatalog.TryGetElementwiseTwin("scalar.no-such@1", out _));
    }

    /// <summary>Verifies the per-row overload equals the form and its validity sibling, with no allocation.</summary>
    [Theory]
    [InlineData("modulo")]
    [InlineData("minimum")]
    [InlineData("maximum")]
    [InlineData("negate")]
    [InlineData("floor")]
    [InlineData("round")]
    public void PerRowValidityEqualsTheFormAndItsSibling(string name) => AssertPerRowValidity(name);

    /// <summary>
    /// Same check for the lifts that arrive with the merge of feat/0.7.0-limits (absolute, add, subtract, multiply,
    /// divide). EXPECTED TO FAIL on this branch alone, where those forms do not exist; it must pass after the merge.
    /// </summary>
    [Theory]
    [InlineData("add")]
    [InlineData("multiply")]
    [InlineData("divide")]
    [InlineData("absolute")]
    [InlineData("subtract")]
    public void PerRowValidityForTheLiftsThatComeWithTheMerge(string name) => AssertPerRowValidity(name);

    private static void AssertPerRowValidity(string name)
    {
        var form = MathBlockCudaDeviceModule.GetOperation($"elementwise.scalar.{name}@1");
        var sibling = MathBlockCudaDeviceModule.GetOperation($"elementwise-valid.scalar.{name}@1");
        double[] bigLeft = [1e300d, 1e308d, -1e308d, 5d, 5d, 5d, -0d, 0d, 7d, 1d, 2d, -3d];
        double[] bigRight = [1e300d, 1e308d, 1e308d, 0d, -0d, 2d, 0d, -0d, 3d, 1e-308d, 1e308d, 0.5d];
        var left = MathBlockValue.Vector(bigLeft);
        var right = MathBlockValue.Vector(bigRight);
        var fill = MathBlockValue.Scalar(-12345d);
        var unary = Array.Exists(new[] { "negate", "floor", "round", "absolute" }, candidate => string.Equals(candidate, name, StringComparison.Ordinal));
        MathBlockValue[] inputs = unary ? [left, fill] : [left, right, fill];
        MathBlockValue[] siblingInputs = unary ? [left] : [left, right];
        var output = new double[bigLeft.Length];
        var rowValid = new bool[bigLeft.Length];

        var evaluation = form.EvaluateCoreCLR(inputs, output, rowValid, MathBlockDomainOptions.Default);
        form.EvaluateCoreCLR(inputs, output, rowValid, MathBlockDomainOptions.Default);
        var before = GC.GetAllocatedBytesForCurrentThread();
        form.EvaluateCoreCLR(inputs, output, rowValid, MathBlockDomainOptions.Default);
        var allocated = GC.GetAllocatedBytesForCurrentThread() - before;

        var expected = form.EvaluateCoreCLR(inputs).AsVector();
        var flags = sibling.EvaluateCoreCLR(siblingInputs).AsBooleanVector();
        Assert.True(evaluation.IsValid);
        Assert.Equal(bigLeft.Length, evaluation.Rows);
        Assert.Equal(0L, allocated);
        for (var index = 0; index < bigLeft.Length; index++)
        {
            Assert.Equal(BitConverter.DoubleToInt64Bits(expected[index]), BitConverter.DoubleToInt64Bits(output[index]));
            Assert.Equal(flags[index], rowValid[index]);
            if (!rowValid[index])
                Assert.Equal(-12345d, output[index]);
        }

        if (string.Equals(name, "divide", StringComparison.Ordinal))
            Assert.Contains(false, rowValid);
    }

    /// <summary>Verifies the per-row overload rejects a non-form, short spans and runs the fallback for an empty vector.</summary>
    [Fact]
    public void PerRowOverloadChecksItsArguments()
    {
        var add = MathBlockCudaDeviceModule.GetOperation("elementwise.scalar.modulo@1");
        var inputs = new[] { MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Vector([1d, 0d, 3d]), MathBlockValue.Scalar(0d) };

        Assert.Throws<InvalidOperationException>(() => MathBlockCudaDeviceModule.GetOperation("vector.add@1")
            .EvaluateCoreCLR(inputs, new double[3], new bool[3], MathBlockDomainOptions.Default));
        Assert.Contains("needs 3 elements", Assert.Throws<ArgumentException>(() => add.EvaluateCoreCLR(inputs, new double[2], new bool[3], MathBlockDomainOptions.Default)).Message, StringComparison.Ordinal);
        Assert.Equal("rowValid", Assert.Throws<ArgumentException>(() => add.EvaluateCoreCLR(inputs, new double[3], new bool[2], MathBlockDomainOptions.Default)).ParamName);
        var empty = new[] { MathBlockValue.Vector([]), MathBlockValue.Vector([]), MathBlockValue.Scalar(0d) };
        var result = add.EvaluateCoreCLR(empty, new double[1], new bool[1], MathBlockDomainOptions.Default);
        Assert.True(result.IsValid);
        Assert.Equal(0, result.Rows);
        var wrongKind = new[] { MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2d), MathBlockValue.Scalar(0d) };
        Assert.Throws<InvalidOperationException>(() => add.EvaluateCoreCLR(wrongKind, new double[1], new bool[1], MathBlockDomainOptions.Default));
    }

    /// <summary>Verifies the documented elementwise device layout against the generated source and the limit records.</summary>
    [Fact]
    public void ElementwiseDeviceLayoutMatchesTheGeneratedSource()
    {
        var source = MathBlockCudaDeviceModule.Source;
        var start = source.LastIndexOf("__device__ void mathblocks_elementwise_run(", StringComparison.Ordinal);
        Assert.True(start >= 0);
        var end = source.IndexOf("\n__device__ ", start + 10, StringComparison.Ordinal);
        var body = end < 0 ? source[start..] : source[start..end];

        Assert.Equal(sizeof(double), MathBlockCudaDeviceModule.ElementwiseValueElementBytes);
        Assert.Equal(sizeof(int), MathBlockCudaDeviceModule.ElementwiseValidityElementBytes);
        Assert.Contains("double* result = ((double*)", body, StringComparison.Ordinal);
        Assert.Contains("int* boolean_result = ((int*)", body, StringComparison.Ordinal);
        Assert.Contains("&((result)[row])", body, StringComparison.Ordinal);
        Assert.Contains("&((boolean_result)[row])", body, StringComparison.Ordinal);
        Assert.Contains("->data_pointer", body, StringComparison.Ordinal);
        Assert.Contains("csharp2cuda_i32_div(opcode, 128)", body, StringComparison.Ordinal);
        Assert.Contains("csharp2cuda_i32_div(form, 2)", body, StringComparison.Ordinal);
        Assert.Contains("csharp2cuda_i32_rem(form, 2)", body, StringComparison.Ordinal);
        Assert.Contains("->scalar_value", body, StringComparison.Ordinal);

        var limits = MathBlockLimits.Resolve();
        Assert.Equal(8, limits.Single(limit => string.Equals(limit.Name, "cuda.elementwise.value-element-bytes", StringComparison.Ordinal)).Value);
        Assert.Equal(4, limits.Single(limit => string.Equals(limit.Name, "cuda.elementwise.validity-element-bytes", StringComparison.Ordinal)).Value);
        Assert.Equal(128, limits.Single(limit => string.Equals(limit.Name, "cuda.elementwise.opcode-mask-multiplier", StringComparison.Ordinal)).Value);
    }

    private static MathBlockValue[] CreateInputs(string identity)
    {
        var left = MathBlockValue.Vector(Left);
        var right = MathBlockValue.Vector(Right);
        var fill = MathBlockValue.Scalar(-12345d);
        return identity switch
        {
            "vector.absolute@1" => [left],
            "elementwise.scalar.negate@1" or "elementwise.scalar.floor@1" or "elementwise.scalar.round@1" => [left, fill],
            "elementwise.scalar.modulo@1" or "elementwise.scalar.minimum@1" or "elementwise.scalar.maximum@1" => [left, right, fill],
            "boolean-vector.not@1" => [MathBlockValue.BooleanVector(FlagsA)],
            "boolean-vector.and@1" or "boolean-vector.or@1" or "boolean-vector.xor@1" =>
                [MathBlockValue.BooleanVector(FlagsA), MathBlockValue.BooleanVector(FlagsB)],
            "vector.select@1" => [MathBlockValue.BooleanVector(FlagsA), left, right],
            _ => [left, right]
        };
    }
}
