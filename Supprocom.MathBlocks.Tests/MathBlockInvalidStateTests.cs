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
            ["matrix.exponential/overflowing-norm"] = ("matrix.exponential@1", () => [Matrix(2, 2, 1.7e308d, 1.7e308d, 0d, 0d)])
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
        Assert.True(declared.Accepts(result.Type), $"{name} returned {result.Type}; the declared type is {declared}.");
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

    private static MathBlockOperation Find(string identity)
    {
        var separator = identity.LastIndexOf('@');
        var identifier = identity[..separator];
        var version = int.Parse(identity[(separator + 1)..], CultureInfo.InvariantCulture);
        return MathBlockCatalog.Standard.Get(identifier, version);
    }

    private static MathBlockValue Scalar(double value) => MathBlockValue.Scalar(value);

    private static MathBlockValue Vector(params double[] values) => MathBlockValue.Vector(values);

    private static MathBlockValue Booleans(params bool[] values) => MathBlockValue.BooleanVector(values);

    private static MathBlockValue ComplexVector(params Complex[] values) => MathBlockValue.ComplexVector(values);

    private static MathBlockValue Matrix(int rows, int columns, params double[] values) =>
        MathBlockValue.Matrix(new MathBlockMatrix(rows, columns, values));

    private static MathBlockValue Points(params (double X, double Y)[] points) =>
        MathBlockValue.PointSet(new MathBlockPointSet(points.Select(point => new MathBlockPoint(point.X, point.Y))));
}
