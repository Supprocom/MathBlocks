using System.Diagnostics;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockRegressionTests
{
    [Fact]
    public void Rational_units_are_canonical_and_support_fractional_dimensions()
    {
        Assert.Equal(new MathRational(1, 2), new MathRational(2, 4));
        Assert.Equal(MathBlockUnit.Basis0,
            MathBlockUnit.Basis0.Pow(new MathRational(2)).Pow(new MathRational(1, 2)));
        Assert.True(default(MathBlockUnit).IsDimensionless);
        Assert.Equal(1, default(MathRational).Denominator);
    }

    [Fact]
    public void Scalar_vector_and_matrix_identities_hold_for_deterministic_samples()
    {
        var random = new Random(924_771);
        for (var sample = 0; sample < 500; sample++)
        {
            var left = random.NextDouble() * 20d - 10d;
            var right = random.NextDouble() * 20d - 10d;
            Assert.Equal(left, MathBlockScalar.Subtract(MathBlockScalar.Add(left, right), right), 11);
        }

        var matrix = new MathBlockMatrix(3, 3,
        [
            2d, -1d, 0d,
            1d, 3d, 2d,
            0d, 1d, 4d
        ]);
        Assert.True(MathBlockLinearAlgebra.TryInverse(matrix, out var inverse));
        var identity = MathBlockLinearAlgebra.Multiply(matrix, inverse!);
        Assert.True(MathBlockValue.Matrix(identity).ApproximatelyEquals(
            MathBlockValue.Matrix(MathBlockLinearAlgebra.Identity(3)), 1e-10));
        Assert.Equal(MathBlockLinearAlgebra.Trace(matrix),
            MathBlockVectorMath.Sum(MathBlockLinearAlgebra.SymmetricEigenvalues(
                new MathBlockMatrix(3, 3, [2d, 1d, 0d, 1d, 3d, 1d, 0d, 1d, 4d]))), 9);
    }

    [Fact]
    public void Fourier_transform_round_trip_restores_the_input()
    {
        var input = new[] { 0.5d, -2d, 3.5d, 1d, -0.25d };
        var transformed = MathBlockPath.DiscreteFourierTransform(input);
        var restored = MathBlockPath.InverseDiscreteFourierTransform(transformed);

        for (var index = 0; index < input.Length; index++)
        {
            Assert.Equal(input[index], restored[index].Real, 10);
            Assert.Equal(0d, restored[index].Imaginary, 10);
        }
    }

    [Fact]
    public void Sinkhorn_coupling_preserves_both_marginals()
    {
        var cost = new MathBlockMatrix(3, 2, [0d, 1d, 1d, 0d, 2d, 1d]);
        var left = new[] { 0.2d, 0.3d, 0.5d };
        var right = new[] { 0.4d, 0.6d };
        var coupling = MathBlockTransport.SinkhornCoupling(cost, left, right, 0.7d, 500);

        for (var row = 0; row < coupling.Rows; row++)
            Assert.Equal(left[row], Enumerable.Range(0, coupling.Columns).Sum(column => coupling[row, column]), 9);
        for (var column = 0; column < coupling.Columns; column++)
            Assert.Equal(right[column], Enumerable.Range(0, coupling.Rows).Sum(row => coupling[row, column]), 9);
    }

    [Fact]
    public void Hodge_potential_exactly_recovers_a_gradient_flow()
    {
        var graph = new MathBlockGraph(4,
        [
            new(0, 1, 2d),
            new(1, 2, -1d),
            new(0, 3, 5d),
            new(2, 3, 4d)
        ]);

        Assert.True(MathBlockGraphMath.TryHodgePotential(graph, out var potential));
        Assert.Equal([0d, 2d, 1d, 5d], potential, new ApproximateDoubleComparer(1e-10));
        Assert.Equal(0d, MathBlockGraphMath.HodgeResidualNorm(graph, potential), 10);
    }

    [Fact]
    public void Geometry_and_path_signature_match_closed_form_results()
    {
        var polygon = new MathBlockPointSet([new(0d, 0d), new(2d, 0d), new(2d, 1d), new(0d, 1d)]);
        Assert.Equal(2d, MathBlockGeometry.PolygonArea(polygon), 12);
        Assert.Equal(6d, MathBlockGeometry.Perimeter(polygon), 12);

        var straightPath = new MathBlockMatrix(2, 2, [0d, 0d, 2d, 3d]);
        Assert.Equal([2d, 3d], MathBlockPath.SignatureLevelOne(straightPath), new ApproximateDoubleComparer(1e-12));
        Assert.True(MathBlockValue.Matrix(MathBlockPath.SignatureLevelTwo(straightPath)).ApproximatelyEquals(
            MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [2d, 3d, 3d, 4.5d])), 1e-12));
    }

    [Fact]
    public void Statistical_and_information_results_match_known_values()
    {
        var values = new[] { 1d, 2d, 3d, 4d };
        Assert.Equal(1.25d, MathBlockStatistics.PopulationVariance(values), 12);
        Assert.Equal(1d, MathBlockStatistics.PearsonCorrelation(values, new[] { 3d, 5d, 7d, 9d }), 12);
        Assert.Equal(Math.Log(2d), MathBlockProbability.ShannonEntropy(new[] { 0.5d, 0.5d }), 12);
        Assert.Equal(0d, MathBlockProbability.JensenShannonDivergence(
            new[] { 0.25d, 0.75d }, new[] { 0.25d, 0.75d }), 12);
    }

    [Fact]
    [Trait("Category", "Performance")]
    public void Bulk_algorithms_complete_bounded_performance_probes()
    {
        var values = Enumerable.Range(0, 200_000).Select(index => Math.Sin(index * 0.01d)).ToArray();
        var watch = Stopwatch.StartNew();
        var rolling = MathBlockVectorMath.RollingMean(values, 128);
        watch.Stop();
        Assert.Equal(values.Length - 127, rolling.Length);
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(5), $"Rolling mean took {watch.Elapsed}.");

        var matrixValues = Enumerable.Range(0, 64 * 64).Select(index => (index % 17 - 8) / 17d).ToArray();
        var matrix = new MathBlockMatrix(64, 64, matrixValues);
        watch.Restart();
        var product = MathBlockLinearAlgebra.Multiply(matrix, MathBlockLinearAlgebra.Transpose(matrix));
        watch.Stop();
        Assert.Equal(64, product.Rows);
        Assert.True(watch.Elapsed < TimeSpan.FromSeconds(5), $"Matrix multiplication took {watch.Elapsed}.");
    }

    private sealed class ApproximateDoubleComparer(double tolerance) : IEqualityComparer<double>
    {
        public bool Equals(double left, double right) =>
            Math.Abs(left - right) <= tolerance * Math.Max(1d, Math.Max(Math.Abs(left), Math.Abs(right)));

        public int GetHashCode(double value) => value.GetHashCode();
    }
}
