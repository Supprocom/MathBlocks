using System.Globalization;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies that out-of-domain inputs give an invalid value of the declared type instead of an exception.</summary>
/// <remarks>
/// <see cref="MathBlockOperation.Evaluate(IReadOnlyList{MathBlockValue})"/> throws when an evaluator returns a type
/// that its declared output type does not accept. An invalid result built from a bare kind such as
/// <c>MathBlockType.Vector()</c> has no length, so it is rejected whenever the declared type knows the length; an
/// empty vector's type has no length either, so a resolver cannot reject it beside a longer vector.
/// </remarks>
public sealed class MathBlockInvalidStateTests
{
    private static readonly Dictionary<string, (string Identity, Func<MathBlockValue[]> Inputs)> Cases =
        new(StringComparer.Ordinal)
        {
            // Invalid results built from a type with no shape or the wrong unit.
            ["complex-matrix.pick/empty-nodes"] = ("complex-matrix.pick@1", () => [ComplexVector(), ComplexVector(new Complex(0.5d, 0d))]),
            ["extension.mcshane/empty-points"] = ("extension.mcshane@1", () => [Vector(), Vector(0d, 2d), Vector(1d), Scalar(1d)]),
            ["extension.whitney/empty-points"] = ("extension.whitney@1", () => [Vector(), Vector(0d, 2d), Vector(1d), Scalar(1d)]),
            ["geometry.delaunay-graph/one-point"] = ("geometry.delaunay-graph@1", () => [Points((0d, 0d))]),
            ["geometry.gabriel-graph/one-point"] = ("geometry.gabriel-graph@1", () => [Points((0d, 0d))]),
            ["graph.hodge-potential/no-edges"] = ("graph.hodge-potential@1", () => [MathBlockValue.Graph(new MathBlockGraph(3, []))]),
            ["matrix.column/index-outside"] = ("matrix.column@1", () => [Matrix(1, 1, 2d), Scalar(1d)]),
            ["matrix.row/index-outside"] = ("matrix.row@1", () => [Matrix(1, 1, 2d), Scalar(1d)]),
            ["matrix.hankel/empty-boundary"] = ("matrix.hankel@1", () => [Vector(), Vector(2d, 3d, 4d)]),
            ["matrix.toeplitz/empty-boundary"] = ("matrix.toeplitz@1", () => [Vector(), Vector(1d, 3d, 4d)]),
            ["matrix.solve/singular"] = ("matrix.solve@1", () => [Matrix(2, 2, 0d, 0d, 0d, 0d), Vector(4d, 8d)]),
            ["matrix.symmetric-eigenvalues/not-symmetric"] = ("matrix.symmetric-eigenvalues@1", () => [Matrix(2, 2, 1d, 2d, 3d, 4d)]),
            ["matrix.maximal-minors/too-many-columns-with-unit"] = ("matrix.maximal-minors@1", () => [MathBlockValue.Matrix(new MathBlockMatrix(1, 21, Enumerable.Range(1, 21).Select(value => (double)value)), MathBlockUnit.Basis0)]),
            ["path.hysteresis/equal-thresholds"] = ("path.hysteresis@1", () => [Vector(-2d, 0d, 2d, 0d, -2d), Scalar(1d), Scalar(1d)]),
            ["survival.discrete-hazard/not-a-distribution"] = ("survival.discrete-hazard@1", () => [Vector(0d)]),
            ["survival.product-limit/empty-events"] = ("survival.product-limit@1", () => [Vector(), Vector(4d, 3d)]),
            ["transport.minimum-assignment/too-large"] = ("transport.minimum-assignment@1", () => [MathBlockValue.Matrix(new MathBlockMatrix(21, 21, Enumerable.Range(0, 441).Select(value => (double)(value % 7))))]),
            ["transport.monotone-coupling/empty-source"] = ("transport.monotone-coupling@1", () => [Vector(), Vector(0.5d, 0.5d)]),
            ["vector.gather/index-outside"] = ("vector.gather@1", () => [Vector(), Vector(3d, 1d)]),
            ["transform.haar/not-a-power-of-two"] = ("transform.haar@1", () => [Vector(1d, 2d, 3d)]),
            ["transport.assignment-cost/non-integer-index"] = ("transport.assignment-cost@1", () => [Matrix(2, 2, 3d, 1d, 1d, 3d), Vector(0.5d, 1d)]),

            // An empty vector beside a longer one: the result was a valid value of the wrong length.
            ["vector.add/empty-left"] = ("vector.add@1", () => [Vector(), Vector(4d, 3d, 2d, 1d)]),
            ["vector.subtract/empty-left"] = ("vector.subtract@1", () => [Vector(), Vector(4d, 3d, 2d, 1d)]),
            ["vector.multiply/empty-left"] = ("vector.multiply@1", () => [Vector(), Vector(4d, 3d, 2d, 1d)]),
            ["vector.divide/empty-left"] = ("vector.divide@1", () => [Vector(), Vector(4d, 3d, 2d, 1d)]),
            ["vector.equal/empty-left"] = ("vector.equal@1", () => [Vector(), Vector(4d, 3d, 2d, 1d)]),
            ["vector.greater-than/empty-left"] = ("vector.greater-than@1", () => [Vector(), Vector(4d, 3d, 2d, 1d)]),
            ["vector.less-than/empty-left"] = ("vector.less-than@1", () => [Vector(), Vector(4d, 3d, 2d, 1d)]),
            ["boolean-vector.and/empty-left"] = ("boolean-vector.and@1", () => [Booleans(), Booleans(true, false, true)]),
            ["boolean-vector.or/empty-left"] = ("boolean-vector.or@1", () => [Booleans(), Booleans(true, false, true)]),
            ["boolean-vector.xor/empty-left"] = ("boolean-vector.xor@1", () => [Booleans(), Booleans(true, false, true)]),
            ["vector.select/empty-mask"] = ("vector.select@1", () => [Booleans(), Vector(1d, 2d), Vector(3d, 4d)]),
            ["complex-vector.create/empty-real"] = ("complex-vector.create@1", () => [Vector(), Vector(2d, 4d)]),
            ["matrix.stack-rows/empty-first"] = ("matrix.stack-rows@1", () => [Vector(), Vector(3d, 4d)]),

            // Results that overflow, which threw from the point and graph-edge validation.
            ["geometry.centroid/overflow"] = ("geometry.centroid@1", () => [Points((1.7e308d, 0d), (1.7e308d, 0d))]),
            ["geometry.delaunay-graph/overflow"] = ("geometry.delaunay-graph@1", () => [Points((0d, 0d), (1e200d, 0d), (0d, 1e200d))]),
            ["geometry.gabriel-graph/overflow"] = ("geometry.gabriel-graph@1", () => [Points((0d, 0d), (1e200d, 0d), (0d, 1e200d))]),
            ["topology.zero-dimensional-persistence/overflow"] = ("topology.zero-dimensional-persistence@1", () => [Points((0d, 0d), (1e200d, 0d), (0d, 1e200d))]),

            // A row norm that overflows asked for int.MaxValue squarings.
            ["matrix.exponential/overflowing-norm"] = ("matrix.exponential@1", () => [Matrix(2, 2, 1.7e308d, 1.7e308d, 0d, 0d)]),

            // An iteration count above 10,000, which graph.page-rank and transport.sinkhorn-coupling already reject;
            // 1e9 iterations ran for minutes.
            ["markov.stationary-distribution/iterations-over-cap"] = ("markov.stationary-distribution@1", () => IterativeInputs("markov.stationary-distribution@1", 10_001d)),
            ["matrix.perron-value/iterations-over-cap"] = ("matrix.perron-value@1", () => IterativeInputs("matrix.perron-value@1", 10_001d)),
            ["matrix.perron-vector/iterations-over-cap"] = ("matrix.perron-vector@1", () => IterativeInputs("matrix.perron-vector@1", 10_001d)),
            ["matrix.spectral-norm/iterations-over-cap"] = ("matrix.spectral-norm@1", () => IterativeInputs("matrix.spectral-norm@1", 10_001d))
        };

    /// <summary>Gets the operations whose second input is an iteration count capped at 10,000.</summary>
    public static TheoryData<string> CappedIterationIdentities =>
        ["markov.stationary-distribution@1", "matrix.perron-value@1", "matrix.perron-vector@1", "matrix.spectral-norm@1"];

    private static readonly double[] ScalarVariants =
        [0d, -0d, -1d, 1d, 2d, 0.5d, -0.5d, 3d, 21d, 65537d, 1e308d, -1e308d, 1e-310d, 4097d, 1_000_001d];

    // Operations whose result shape is not a function of the input types, so their declared type leaves it out.
    private static readonly Dictionary<string, string> UndeclaredShapes = new(StringComparer.Ordinal)
    {
        // CUDA sizes this result by an upper bound, C(columns, min(rows, columns / 2)), not the exact count
        // C(columns, rows), so no declared length would equal its slot shape for every matrix shape.
        ["matrix.maximal-minors@1"] = "the minor count is C(columns, rows), which the resolver does not compute"
    };

    /// <summary>Gets the out-of-domain case names.</summary>
    public static TheoryData<string> CaseNames => [.. Cases.Keys.Order(StringComparer.Ordinal)];

    /// <summary>Verifies one out-of-domain case gives an invalid value of the declared type.</summary>
    [Theory]
    [MemberData(nameof(CaseNames))]
    [Trait("Category", "InvalidState")]
    public async Task OutOfDomainInputsGiveAnInvalidValueOfTheDeclaredType(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        var (identity, create) = Cases[name];
        var operation = Find(identity);
        var inputs = create();
        var declared = operation.ResolveOutputType(inputs.Select(input => input.Type).ToArray());

        // matrix.exponential used to run for int.MaxValue squarings here; the time limit turns that into a failure.
        var result = await Task.Run(() => operation.Evaluate(inputs)).WaitAsync(TimeSpan.FromSeconds(60));

        Assert.False(result.IsValid, $"{name} returned a valid {result.Type}.");
        Assert.Equal(declared, result.Type);
    }

    /// <summary>Verifies an iteration count of exactly 10,000 still gives a valid result.</summary>
    [Theory]
    [MemberData(nameof(CappedIterationIdentities))]
    [Trait("Category", "InvalidState")]
    public void IterationCountsUpToTheCapGiveAValidResult(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var result = Find(identity).Evaluate(IterativeInputs(identity, 10_000d));

        Assert.True(result.IsValid, $"{identity} returned {result.InvalidReason}");
    }

    // The operation's first regression case with its iteration count (the second input) replaced.
    private static MathBlockValue[] IterativeInputs(string identity, double iterations)
    {
        var inputs = Find(identity).RegressionCases[0].Inputs.ToArray();
        inputs[1] = MathBlockValue.Scalar(iterations, inputs[1].Type.Unit);
        return inputs;
    }

    /// <summary>
    /// Verifies each operation with an out-of-domain case declares the shape of its valid results, so an invalid
    /// value built from the declared type carries the shape a valid result would have (as the CUDA result type does).
    /// </summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void OperationsWithOutOfDomainCasesDeclareTheShapeOfTheirValidResults()
    {
        var failures = new List<string>();
        foreach (var identity in Cases.Values.Select(item => item.Identity).Distinct(StringComparer.Ordinal).Order(StringComparer.Ordinal))
        {
            if (UndeclaredShapes.ContainsKey(identity))
                continue;
            var operation = Find(identity);
            foreach (var regression in operation.RegressionCases)
            {
                var declared = operation.ResolveOutputType(regression.Inputs.Select(input => input.Type).ToArray());
                var result = operation.Evaluate(regression.Inputs);
                if (!result.IsValid || declared != result.Type)
                    failures.Add($"{identity}/{regression.Name}: declared {declared}, result {result.Type} ({(result.IsValid ? "valid" : result.InvalidReason)})");
            }
        }
        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    /// <summary>Verifies the rolling variance is in the square of the input unit.</summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void RollingVarianceIsInTheSquareOfTheInputUnit()
    {
        var operation = MathBlockCatalog.Standard.Get("sequence.rolling-variance");
        var unit = MathBlockUnit.Basis0;
        MathBlockValue[] inputs = [MathBlockValue.Vector([1d, 2d, 4d, 8d], unit), Scalar(2d)];
        var squared = unit.Pow(new MathRational(2));

        Assert.Equal(squared, operation.ResolveOutputType(inputs.Select(input => input.Type).ToArray()).Unit);
        var result = operation.Evaluate(inputs);
        Assert.True(result.IsValid);
        Assert.Equal(squared, result.Type.Unit);
        var tooWide = operation.Evaluate(MathBlockValue.Vector([1d, 2d], unit), Scalar(3d));
        Assert.False(tooWide.IsValid);
        Assert.Equal(squared, tooWide.Type.Unit);
    }

    /// <summary>
    /// Evaluates every operation of the standard, window and elementwise registries on its samples with inputs
    /// replaced by out-of-domain values, and requires a value of a type its declared type accepts whenever the type
    /// resolves, and an invalid value of exactly the declared type: an exception from Evaluate past type resolution
    /// is a failure.
    /// </summary>
    [Fact]
    [Trait("Category", "InvalidState")]
    public void EveryOperationReturnsAValueForOutOfDomainInputs()
    {
        var operations = MathBlockCatalog.Standard.Operations
            .Concat(MathBlockWindowTestSupport.Windowed.Operations)
            .Concat(MathBlockElementwiseTestSupport.Elementwise.Operations);
        var failures = new SortedDictionary<string, string>(StringComparer.Ordinal);
        var evaluations = 0;
        foreach (var operation in operations)
        {
            foreach (var inputs in Variants(operation))
            {
                MathBlockType declared;
                try
                {
                    declared = operation.ResolveOutputType(inputs.Select(input => input.Type).ToArray());
                }
                catch (Exception exception) when (exception is InvalidOperationException or ArgumentException)
                {
                    continue;
                }
                evaluations++;
                try
                {
                    var result = operation.Evaluate(inputs);
                    if (!declared.Accepts(result.Type))
                        failures.TryAdd(operation.Identity, $"returned {result.Type} for the declared {declared}");
                    else if (!result.IsValid && result.Type != declared)
                        failures.TryAdd(operation.Identity, $"returned an invalid {result.Type}, not the declared {declared} ({Describe(inputs)})");
                }
                catch (Exception exception) when (exception is not OutOfMemoryException)
                {
                    failures.TryAdd(operation.Identity, $"{exception.GetType().Name}: {exception.Message} ({Describe(inputs)})");
                }
            }
        }

        Assert.True(evaluations > 10_000, $"Only {evaluations} evaluations ran.");
        Assert.True(
            failures.Count == 0,
            string.Create(CultureInfo.InvariantCulture, $"{failures.Count} operation(s) threw:{Environment.NewLine}{string.Join(Environment.NewLine, failures.Select(item => $"{item.Key}: {item.Value}"))}"));
    }

    private static MathBlockOperation Find(string identity)
    {
        var separator = identity.LastIndexOf('@');
        var identifier = identity[..separator];
        var version = int.Parse(identity[(separator + 1)..], CultureInfo.InvariantCulture);
        return MathBlockCatalog.Standard.Get(identifier, version);
    }

    // Each sample (the performance case and every regression case), the sample with every input in one unit, and
    // the sample with one input at a time in a unit; for each, every input replaced by each of its kind's variants,
    // then every input replaced by its variant of the same index.
    private static IEnumerable<MathBlockValue[]> Variants(MathBlockOperation operation)
    {
        var samples = new List<MathBlockValue[]> { operation.PerformanceCase.Inputs.ToArray() };
        samples.AddRange(operation.RegressionCases.Select(item => item.Inputs.ToArray()));
        var plain = samples.Count;
        for (var index = 0; index < plain; index++)
        {
            samples.Add(samples[index].Select(value => WithUnit(value, MathBlockUnit.Basis0)).ToArray());
            for (var input = 0; input < samples[index].Length; input++)
            {
                var single = (MathBlockValue[])samples[index].Clone();
                single[input] = WithUnit(single[input], MathBlockUnit.Basis1);
                samples.Add(single);
            }
        }
        for (var index = 0; index < samples.Count; index++)
        {
            var sample = samples[index];
            yield return sample;
            var alternatives = sample.Select(Alternatives).ToArray();
            for (var input = 0; input < sample.Length; input++)
                for (var variant = 0; variant < alternatives[input].Count; variant++)
                {
                    var inputs = (MathBlockValue[])sample.Clone();
                    inputs[input] = alternatives[input][variant];
                    yield return inputs;
                }
            var widest = alternatives.Max(list => list.Count);
            for (var variant = 0; variant < widest; variant++)
            {
                var inputs = new MathBlockValue[sample.Length];
                for (var input = 0; input < sample.Length; input++)
                    inputs[input] = alternatives[input].Count == 0 ? sample[input] : alternatives[input][variant % alternatives[input].Count];
                yield return inputs;
            }
        }
    }

    private static List<MathBlockValue> Alternatives(MathBlockValue value)
    {
        var list = new List<MathBlockValue>();
        if (!value.IsValid)
            return list;
        var unit = value.Type.Unit;
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                list.AddRange(ScalarVariants.Select(item => MathBlockValue.Scalar(item, unit)));
                break;
            case MathBlockValueKind.Boolean:
                list.Add(MathBlockValue.Boolean(!value.AsBoolean()));
                break;
            case MathBlockValueKind.Complex:
                list.Add(MathBlockValue.Complex(new Complex(0d, 0d), unit));
                list.Add(MathBlockValue.Complex(new Complex(1.7e308d, 1.7e308d), unit));
                break;
            case MathBlockValueKind.Vector:
                {
                    var values = value.AsVector().ToArray();
                    var count = values.Length;
                    list.Add(MathBlockValue.Vector([], unit));
                    list.Add(MathBlockValue.Vector([0d], unit));
                    list.Add(MathBlockValue.Vector(new double[count], unit));
                    list.Add(MathBlockValue.Vector(values.Select(item => -item - 1d), unit));
                    list.Add(MathBlockValue.Vector(Enumerable.Repeat(1d, count), unit));
                    list.Add(MathBlockValue.Vector(Enumerable.Repeat(1e308d, count), unit));
                    list.Add(MathBlockValue.Vector(Enumerable.Range(0, Math.Max(count, 2)).Select(item => item % 2 == 0 ? 1.7e308d : -1.7e308d), unit));
                    list.Add(MathBlockValue.Vector(values.Select(item => item + 0.5d), unit));
                    list.Add(MathBlockValue.Vector([.. values, count == 0 ? 1d : values[^1]], unit));
                    list.Add(MathBlockValue.Vector(Enumerable.Range(0, 7).Select(item => (double)item), unit));
                    break;
                }
            case MathBlockValueKind.BooleanVector:
                {
                    var values = value.AsBooleanVector().ToArray();
                    list.Add(MathBlockValue.BooleanVector([]));
                    list.Add(MathBlockValue.BooleanVector(new bool[values.Length]));
                    list.Add(MathBlockValue.BooleanVector([.. values, true]));
                    break;
                }
            case MathBlockValueKind.Matrix:
                {
                    var matrix = value.AsMatrix();
                    var entries = matrix.ToArray();
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, new double[entries.Length]), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, entries.Select((_, index) => index % 2 == 0 ? 1.7e308d : -1.7e308d)), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, Enumerable.Repeat(1e308d, entries.Length)), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(1, 1, [2d]), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(2, 3, [1d, 2d, 3d, 4d, 5d, 6d]), unit));
                    list.Add(MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 1d, 1d, 1d]), unit));
                    break;
                }
            case MathBlockValueKind.ComplexVector:
                {
                    var count = value.AsComplexVector().Count;
                    list.Add(MathBlockValue.ComplexVector([], unit));
                    list.Add(MathBlockValue.ComplexVector(new Complex[count], unit));
                    list.Add(MathBlockValue.ComplexVector(Enumerable.Repeat(new Complex(1.7e308d, 1.7e308d), Math.Max(count, 1)), unit));
                    break;
                }
            case MathBlockValueKind.PointSet:
                {
                    var count = value.AsPointSet().Count;
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet([]), unit));
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet([new MathBlockPoint(0d, 0d)]), unit));
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Repeat(new MathBlockPoint(1d, 1d), count)), unit));
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Range(0, count).Select(index => new MathBlockPoint(index * 1e200d, (index % 2) * 1e200d))), unit));
                    list.Add(MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Range(0, count).Select(index => new MathBlockPoint(index % 2 == 0 ? 1.7e308d : -1.7e308d, index % 3 == 0 ? -1.7e308d : 1.7e308d))), unit));
                    break;
                }
            case MathBlockValueKind.Graph:
                {
                    var graph = value.AsGraph();
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(1, []), unit));
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount, []), unit));
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount, graph.Select(edge => edge with { Weight = -edge.Weight - 1d })), unit));
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount, graph.Select(edge => edge with { Weight = 1e308d })), unit));
                    list.Add(MathBlockValue.Graph(new MathBlockGraph(graph.VertexCount + 1, graph), unit));
                    break;
                }
        }
        return list;
    }

    private static MathBlockValue WithUnit(MathBlockValue value, MathBlockUnit unit)
    {
        if (!value.IsValid)
            return value;
        return value.Type.Kind switch
        {
            MathBlockValueKind.Scalar => MathBlockValue.Scalar(value.AsScalar(), unit),
            MathBlockValueKind.Complex => MathBlockValue.Complex(value.AsComplex(), unit),
            MathBlockValueKind.Vector => MathBlockValue.Vector(value.AsVector(), unit),
            MathBlockValueKind.Matrix => MathBlockValue.Matrix(value.AsMatrix(), unit),
            MathBlockValueKind.ComplexVector => MathBlockValue.ComplexVector(value.AsComplexVector(), unit),
            MathBlockValueKind.ComplexMatrix => MathBlockValue.ComplexMatrix(value.AsComplexMatrix(), unit),
            MathBlockValueKind.PointSet => MathBlockValue.PointSet(value.AsPointSet(), unit),
            MathBlockValueKind.Graph => MathBlockValue.Graph(value.AsGraph(), unit),
            MathBlockValueKind.RunSet => MathBlockValue.RunSet(value.AsRunSet(), unit),
            _ => value
        };
    }

    private static string Describe(MathBlockValue[] inputs) =>
        string.Join(", ", inputs.Select(input => input.IsValid && input.Type.Kind == MathBlockValueKind.Scalar
            ? input.AsScalar().ToString("R", CultureInfo.InvariantCulture)
            : input.Type.ToString()));

    private static MathBlockValue Scalar(double value) => MathBlockValue.Scalar(value);

    private static MathBlockValue Vector(params double[] values) => MathBlockValue.Vector(values);

    private static MathBlockValue Booleans(params bool[] values) => MathBlockValue.BooleanVector(values);

    private static MathBlockValue ComplexVector(params Complex[] values) => MathBlockValue.ComplexVector(values);

    private static MathBlockValue Matrix(int rows, int columns, params double[] values) =>
        MathBlockValue.Matrix(new MathBlockMatrix(rows, columns, values));

    private static MathBlockValue Points(params (double X, double Y)[] points) =>
        MathBlockValue.PointSet(new MathBlockPointSet(points.Select(point => new MathBlockPoint(point.X, point.Y))));
}
