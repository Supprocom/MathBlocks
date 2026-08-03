using System.Diagnostics;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockDomainTests
{
    [Fact]
    public void Jensen_shannon_accepts_disjoint_support()
    {
        var result = MathBlockCatalog.Standard.Get("information.jensen-shannon").Evaluate(
            MathBlockValue.Vector([1d, 0d]),
            MathBlockValue.Vector([0d, 1d]));

        Assert.True(result.IsValid, result.InvalidReason);
        Assert.Equal(Math.Log(2d), result.AsScalar(), 12);
    }

    [Fact]
    public void Invalid_discrete_domains_fail_closed_without_throwing()
    {
        var identity = MathBlockCatalog.Standard.Get("matrix.identity").Evaluate(MathBlockValue.Scalar(2.5d));
        var median = MathBlockCatalog.Standard.Get("vector.median").Evaluate(MathBlockValue.Vector([]));
        var lag = MathBlockCatalog.Standard.Get("statistics.autocorrelation").Evaluate(
            MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Scalar(1.5d));

        Assert.False(identity.IsValid);
        Assert.False(median.IsValid);
        Assert.False(lag.IsValid);
    }

    [Fact]
    public void Generic_dimensions_follow_mathematical_algebra()
    {
        var unit = MathBlockUnit.Basis1;
        var product = MathBlockCatalog.Standard.Get("vector.product").Evaluate(
            MathBlockValue.Vector([2d, 3d, 4d], unit));
        var squareRoot = MathBlockCatalog.Standard.Get("scalar.square-root").Evaluate(
            MathBlockValue.Scalar(9d, unit.Pow(new MathRational(2))));

        Assert.Equal(unit.Pow(new MathRational(3)), product.Type.Unit);
        Assert.Equal(unit, squareRoot.Type.Unit);
        Assert.Equal(24d, product.AsScalar());
        Assert.Equal(3d, squareRoot.AsScalar());
    }

    [Fact]
    public void Operations_reject_dimensionally_invalid_transcendental_inputs()
    {
        var operation = MathBlockCatalog.Standard.Get("probability.softmax");

        Assert.Throws<InvalidOperationException>(() =>
            operation.ResolveOutputType([MathBlockType.Vector(MathBlockUnit.Basis0, 3)]));
    }

    [Fact]
    public void Generic_graph_supports_empty_graphs_self_loops_and_signed_spanning_edges()
    {
        var empty = new MathBlockGraph(0, []);
        var loop = new MathBlockGraph(1, [new MathBlockGraphEdge(0, 0, -2d)]);
        var signed = new MathBlockGraph(3,
        [
            new(0, 1, -2d),
            new(1, 2, 1d),
            new(0, 2, 3d)
        ]);

        Assert.Equal(0, MathBlockGraphMath.ConnectedComponentCount(empty));
        Assert.True(MathBlockGraphMath.IsConnected(loop));
        Assert.Equal([-2d, 1d],
            MathBlockGraphMath.MinimumSpanningForest(signed).Select(edge => edge.Weight));
    }

    [Fact]
    [Trait("Category", "Performance")]
    public void Complex_operation_families_complete_scale_probes()
    {
        var watch = Stopwatch.StartNew();

        var dftInput = Enumerable.Range(0, 1_024).Select(index => Math.Sin(index * 0.03d)).ToArray();
        Assert.Equal(1_024, MathBlockPath.DiscreteFourierTransform(dftInput).Length);

        var costValues = new double[64 * 64];
        for (var row = 0; row < 64; row++)
            for (var column = 0; column < 64; column++)
                costValues[row * 64 + column] = Math.Abs(row - column) / 64d;
        var mass = Enumerable.Repeat(1d / 64d, 64).ToArray();
        Assert.Equal(64, MathBlockTransport.SinkhornCoupling(
            new MathBlockMatrix(64, 64, costValues), mass, mass, 0.2d, 200).Rows);

        var points = Enumerable.Range(0, 50)
            .Select(index => new MathBlockPoint(Math.Cos(index), Math.Sin(index) + index * 0.001d))
            .ToArray();
        Assert.Equal(50, MathBlockGeometry.DelaunayGraph(points).VertexCount);

        var coalitionValues = Enumerable.Range(0, 1 << 15)
            .Select(mask => (double)System.Numerics.BitOperations.PopCount((uint)mask))
            .ToArray();
        Assert.Equal(15, MathBlockAdvanced.ShapleyValues(coalitionValues).Length);

        var pathValues = new double[1_000 * 4];
        for (var index = 0; index < pathValues.Length; index++)
            pathValues[index] = Math.Sin(index * 0.01d);
        Assert.Equal(64, MathBlockAdvanced.SignatureLevelThree(
            new MathBlockMatrix(1_000, 4, pathValues)).Length);

        watch.Stop();
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(10), $"Scale probes took {watch.Elapsed}.");
    }
}
