using System.Diagnostics;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Regression Tests.</summary>
public sealed class MathBlockRegressionTests
{
    /// <summary>Verifies rational units are canonical and support fractional dimensions.</summary>
    [Fact]
    public void RationalUnitsAreCanonicalAndSupportFractionalDimensions()
    {
        Assert.Equal(new MathRational(1, 2), new MathRational(2, 4));
        Assert.Equal(MathBlockUnit.Basis0,
            MathBlockUnit.Basis0.Pow(new MathRational(2)).Pow(new MathRational(1, 2)));
        Assert.True(default(MathBlockUnit).IsDimensionless);
        Assert.Equal(1, default(MathRational).Denominator);
    }

    /// <summary>Verifies scalar vector and matrix identities hold for deterministic samples.</summary>
    [Fact]
    public void ScalarVectorAndMatrixIdentitiesHoldForDeterministicSamples()
    {
        var random = new Random(924_771);
        for (var sample = 0; sample < 500; sample++)
        {
            var left = random.NextSingle() * 20f - 10f;
            var addend = random.NextSingle() * 20f - 10f;
            Assert.Equal(left, MathBlockScalar.Subtract(MathBlockScalar.Add(left, addend), addend), 5);
        }

        var matrix = new MathBlockMatrix(3, 3,
        [
            2f, -1f, 0f,
            1f, 3f, 2f,
            0f, 1f, 4f
        ]);
        Assert.True(MathBlockLinearAlgebra.TryInverse(matrix, out var inverse));
        var identity = MathBlockLinearAlgebra.Multiply(matrix, inverse!);
        Assert.True(MathBlockValue.Matrix(identity).ApproximatelyEquals(
            MathBlockValue.Matrix(MathBlockLinearAlgebra.Identity(3)), 1e-10f));
        Assert.Equal(MathBlockLinearAlgebra.Trace(matrix),
            MathBlockVectorMath.Sum(MathBlockLinearAlgebra.SymmetricEigenvalues(
                new MathBlockMatrix(3, 3, [2f, 1f, 0f, 1f, 3f, 1f, 0f, 1f, 4f]))), 9);
    }

    /// <summary>Verifies fourier transform round trip restores the input.</summary>
    [Fact]
    public void FourierTransformRoundTripRestoresTheInput()
    {
        var input = new[] { 0.5f, -2f, 3.5f, 1f, -0.25f };
        var transformed = MathBlockPath.DiscreteFourierTransform(input);
        var restored = MathBlockPath.InverseDiscreteFourierTransform(transformed);

        for (var index = 0; index < input.Length; index++)
        {
            Assert.Equal(input[index], restored[index].Real, 5);
            Assert.Equal(0f, restored[index].Imaginary, 5);
        }
    }

    /// <summary>Verifies sinkhorn coupling preserves both marginals.</summary>
    [Fact]
    public void SinkhornCouplingPreservesBothMarginals()
    {
        var cost = new MathBlockMatrix(3, 2, [0f, 1f, 1f, 0f, 2f, 1f]);
        var left = new[] { 0.2f, 0.3f, 0.5f };
        var rightMarginal = new[] { 0.4f, 0.6f };
        var coupling = MathBlockTransport.SinkhornCoupling(cost, left, rightMarginal, 0.7f, 500);

        for (var row = 0; row < coupling.Rows; row++)
            Assert.Equal(left[row], Enumerable.Range(0, coupling.Columns).Sum(column => coupling[row, column]), 5);
        for (var column = 0; column < coupling.Columns; column++)
            Assert.Equal(rightMarginal[column], Enumerable.Range(0, coupling.Rows).Sum(row => coupling[row, column]), 5);
    }

    /// <summary>Verifies hodge potential exactly recovers agradient flow.</summary>
    [Fact]
    public void HodgePotentialExactlyRecoversAGradientFlow()
    {
        var graph = new MathBlockGraph(4,
        [
            new(0, 1, 2f),
            new(1, 2, -1f),
            new(0, 3, 5f),
            new(2, 3, 4f)
        ]);

        Assert.True(MathBlockGraphMath.TryHodgePotential(graph, out var potential));
        Assert.Equal([0f, 2f, 1f, 5f], potential, new ApproximateDoubleComparer(1e-10f));
        Assert.Equal(0f, MathBlockGraphMath.HodgeResidualNorm(graph, potential), 5);
    }

    /// <summary>Verifies geometry and path signature match closed form results.</summary>
    [Fact]
    public void GeometryAndPathSignatureMatchClosedFormResults()
    {
        var polygon = new MathBlockPointSet([new(0f, 0f), new(2f, 0f), new(2f, 1f), new(0f, 1f)]);
        Assert.Equal(2f, MathBlockGeometry.PolygonArea(polygon), 5);
        Assert.Equal(6f, MathBlockGeometry.Perimeter(polygon), 5);

        var straightPath = new MathBlockMatrix(2, 2, [0f, 0f, 2f, 3f]);
        Assert.Equal([2f, 3f], MathBlockPath.SignatureLevelOne(straightPath), new ApproximateDoubleComparer(1e-12f));
        Assert.True(MathBlockValue.Matrix(MathBlockPath.SignatureLevelTwo(straightPath)).ApproximatelyEquals(
            MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [2f, 3f, 3f, 4.5f])), 1e-12f));
    }

    private static readonly float[] right = new[] { 3f, 5f, 7f, 9f };

    /// <summary>Verifies statistical and information results match known values.</summary>
    [Fact]
    public void StatisticalAndInformationResultsMatchKnownValues()
    {
        var values = new[] { 1f, 2f, 3f, 4f };
        Assert.Equal(1.25f, MathBlockStatistics.PopulationVariance(values), 5);
        Assert.Equal(1f, MathBlockStatistics.PearsonCorrelation(values, right), 5);
        Assert.Equal(MathF.Log(2f), MathBlockProbability.ShannonEntropy(new[] { 0.5f, 0.5f }), 5);
        Assert.Equal(0f, MathBlockProbability.JensenShannonDivergence(
            new[] { 0.25f, 0.75f }, new[] { 0.25f, 0.75f }), 12);
    }

    /// <summary>Verifies bulk algorithms complete bounded performance probes.</summary>
    [Fact]
    [Trait("Category", "Performance")]
    public void BulkAlgorithmsCompleteBoundedPerformanceProbes()
    {
        var values = Enumerable.Range(0, 200_000).Select(index => MathF.Sin(index * 0.01f)).ToArray();
        var watch = Stopwatch.StartNew();
        var rolling = MathBlockVectorMath.RollingMean(values, 128);
        watch.Stop();
        Assert.Equal(values.Length - 127, rolling.Length);
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(5), $"Rolling mean took {watch.Elapsed}.");

        var matrixValues = Enumerable.Range(0, 64 * 64).Select(index => (index % 17 - 8) / 17f).ToArray();
        var matrix = new MathBlockMatrix(64, 64, matrixValues);
        watch.Restart();
        var product = MathBlockLinearAlgebra.Multiply(matrix, MathBlockLinearAlgebra.Transpose(matrix));
        watch.Stop();
        Assert.Equal(64, product.Rows);
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(5), $"Matrix multiplication took {watch.Elapsed}.");
    }

    private sealed class ApproximateDoubleComparer(float tolerance) : IEqualityComparer<float>
    {
        public bool Equals(float left, float right) =>
            Math.Abs(left - right) <= tolerance * Math.Max(1f, Math.Max(Math.Abs(left), Math.Abs(right)));

        public int GetHashCode(float value) => value.GetHashCode();
    }
}
