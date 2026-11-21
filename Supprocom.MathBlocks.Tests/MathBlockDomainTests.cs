using System.Diagnostics;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Domain Tests.</summary>
public sealed class MathBlockDomainTests
{
    /// <summary>Verifies jensen shannon accepts disjoint support.</summary>
    [Fact]
    public void JensenShannonAcceptsDisjointSupport()
    {
        var result = MathBlockCatalog.Standard.Get("information.jensen-shannon").Evaluate(
            MathBlockValue.Vector([1f, 0f]),
            MathBlockValue.Vector([0f, 1f]));

        Assert.True(result.IsValid, result.InvalidReason);
        Assert.Equal(MathF.Log(2f), result.AsScalar(), 5);
    }

    /// <summary>Verifies invalid discrete domains fail closed without throwing.</summary>
    [Fact]
    public void InvalidDiscreteDomainsFailClosedWithoutThrowing()
    {
        var identity = MathBlockCatalog.Standard.Get("matrix.identity").Evaluate(MathBlockValue.Scalar(2.5f));
        var median = MathBlockCatalog.Standard.Get("vector.median").Evaluate(MathBlockValue.Vector([]));
        var lag = MathBlockCatalog.Standard.Get("statistics.autocorrelation").Evaluate(
            MathBlockValue.Vector([1f, 2f, 3f]), MathBlockValue.Scalar(1.5f));

        Assert.False(identity.IsValid);
        Assert.False(median.IsValid);
        Assert.False(lag.IsValid);
    }

    /// <summary>Verifies generic dimensions follow mathematical algebra.</summary>
    [Fact]
    public void GenericDimensionsFollowMathematicalAlgebra()
    {
        var unit = MathBlockUnit.Basis1;
        var product = MathBlockCatalog.Standard.Get("vector.product").Evaluate(
            MathBlockValue.Vector([2f, 3f, 4f], unit));
        var squareRoot = MathBlockCatalog.Standard.Get("scalar.square-root").Evaluate(
            MathBlockValue.Scalar(9f, unit.Pow(new MathRational(2))));

        Assert.Equal(unit.Pow(new MathRational(3)), product.Type.Unit);
        Assert.Equal(unit, squareRoot.Type.Unit);
        Assert.Equal(24f, product.AsScalar());
        Assert.Equal(3f, squareRoot.AsScalar());
    }

    /// <summary>Verifies operations reject dimensionally invalid transcendental inputs.</summary>
    [Fact]
    public void OperationsRejectDimensionallyInvalidTranscendentalInputs()
    {
        var operation = MathBlockCatalog.Standard.Get("probability.softmax");

        Assert.Throws<InvalidOperationException>(() =>
            operation.ResolveOutputType([MathBlockType.Vector(MathBlockUnit.Basis0, 3)]));
    }

    /// <summary>Verifies generic graph supports empty graphs self loops and signed spanning edges.</summary>
    [Fact]
    public void GenericGraphSupportsEmptyGraphsSelfLoopsAndSignedSpanningEdges()
    {
        var empty = new MathBlockGraph(0, []);
        var loop = new MathBlockGraph(1, [new MathBlockGraphEdge(0, 0, -2f)]);
        var signed = new MathBlockGraph(3,
        [
            new(0, 1, -2f),
            new(1, 2, 1f),
            new(0, 2, 3f)
        ]);

        Assert.Equal(0, MathBlockGraphMath.ConnectedComponentCount(empty));
        Assert.True(MathBlockGraphMath.IsConnected(loop));
        Assert.Equal([-2f, 1f],
            MathBlockGraphMath.MinimumSpanningForest(signed).Select(edge => edge.Weight));
    }

    /// <summary>Verifies complex operation families complete scale probes.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void ComplexOperationFamiliesCompleteScaleProbes()
    {
        var watch = Stopwatch.StartNew();

        var dftInput = Enumerable.Range(0, 1_024).Select(index => MathF.Sin(index * 0.03f)).ToArray();
        Assert.Equal(1_024, MathBlockPath.DiscreteFourierTransform(dftInput).Length);

        var costValues = new float[64 * 64];
        for (var row = 0; row < 64; row++)
            for (var column = 0; column < 64; column++)
                costValues[row * 64 + column] = Math.Abs(row - column) / 64f;
        var mass = Enumerable.Repeat(1f / 64f, 64).ToArray();
        Assert.Equal(64, MathBlockTransport.SinkhornCoupling(
            new MathBlockMatrix(64, 64, costValues), mass, mass, 0.2f, 200).Rows);

        var points = Enumerable.Range(0, 50)
            .Select(index => new MathBlockPoint(MathF.Cos(index), MathF.Sin(index) + index * 0.001f))
            .ToArray();
        Assert.Equal(50, MathBlockGeometry.DelaunayGraph(points).VertexCount);

        var coalitionValues = Enumerable.Range(0, 1 << 15)
            .Select(mask => (float)System.Numerics.BitOperations.PopCount((uint)mask))
            .ToArray();
        Assert.Equal(15, MathBlockAdvanced.ShapleyValues(coalitionValues).Length);

        var pathValues = new float[1_000 * 4];
        for (var index = 0; index < pathValues.Length; index++)
            pathValues[index] = MathF.Sin(index * 0.01f);
        Assert.Equal(64, MathBlockAdvanced.SignatureLevelThree(
            new MathBlockMatrix(1_000, 4, pathValues)).Length);

        watch.Stop();
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(10), $"Scale probes took {watch.Elapsed}.");
    }
}
