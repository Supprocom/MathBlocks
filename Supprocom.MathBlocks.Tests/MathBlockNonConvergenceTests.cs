namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains the CoreCLR tests of the incomplete-beta and Jacobi non-convergence options, policies and counters.</summary>
public sealed class MathBlockNonConvergenceTests
{
    private const string Beta = "special.regularized-incomplete-beta@1";
    private const double Large = 1e6;

    private static MathBlockProgram Program(string identifier, params MathBlockType[] inputTypes)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var inputs = inputTypes.Select((type, index) => builder.Input($"input{index}", type)).ToArray();
        return builder.Output("result", builder.Apply(identifier, 1, inputs)).Build();
    }

    private static Dictionary<string, MathBlockValue> Named(params MathBlockValue[] values) =>
        values.Select((value, index) => (Name: $"input{index}", Value: value)).ToDictionary(item => item.Name, item => item.Value, StringComparer.Ordinal);

    private static MathBlockExecutionResult Beta1(MathBlockDomainOptions options, double x = 0.5d, double left = Large, double right = Large)
    {
        var program = Program("special.regularized-incomplete-beta", MathBlockType.Scalar(), MathBlockType.Scalar(), MathBlockType.Scalar());
        return MathBlocksCoreCLRWorker.Create(options).ExecuteWithDiagnostics(
            program,
            Named(MathBlockValue.Scalar(x), MathBlockValue.Scalar(left), MathBlockValue.Scalar(right)));
    }

    /// <summary>Verifies the continued fraction does not converge at 256 iterations and converges from 513, at a = b = 1e6 and x = 0.5.</summary>
    [Theory]
    [InlineData(256, false)]
    [InlineData(513, true)]
    [InlineData(1_024, true)]
    public void TheContinuedFractionConvergesOnlyWithEnoughIterations(int iterations, bool converges)
    {
        var result = Beta1(new MathBlockDomainOptions { IncompleteBetaMaximumIterations = iterations });

        Assert.True(result.Outputs["result"].IsValid);
        if (converges)
            Assert.Empty(result.NonConvergedEvaluations);
        else
            Assert.Equal(1L, Assert.Single(result.NonConvergedEvaluations, pair => string.Equals(pair.Key, Beta, StringComparison.Ordinal)).Value);
    }

    /// <summary>Verifies under Estimate the non-converged row keeps the value earlier versions returned, and is counted once.</summary>
    [Fact]
    public void EstimateKeepsTheValueAndCountsTheEvaluation()
    {
        var result = Beta1(MathBlockDomainOptions.Default);

        Assert.Equal(1L, Assert.Single(result.NonConvergedEvaluations).Value);
        Assert.Equal(Beta, Assert.Single(result.NonConvergedEvaluations).Key);
        Assert.Equal(
            BitConverter.DoubleToInt64Bits(MathBlockProbability.RegularizedIncompleteBeta(0.5d, Large, Large)),
            BitConverter.DoubleToInt64Bits(result.Outputs["result"].AsScalar()));
        Assert.Equal(
            BitConverter.DoubleToInt64Bits(result.Outputs["result"].AsScalar()),
            BitConverter.DoubleToInt64Bits(Operation(Beta).Evaluate(MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(Large), MathBlockValue.Scalar(Large)).AsScalar()));
    }

    /// <summary>Verifies under Invalid the non-converged row is invalid, and still counted.</summary>
    [Fact]
    public void InvalidMakesTheRowInvalidAndCountsTheEvaluation()
    {
        var result = Beta1(new MathBlockDomainOptions { IncompleteBetaNonConvergence = MathBlockNonConvergencePolicy.Invalid });

        Assert.False(result.Outputs["result"].IsValid);
        Assert.Equal(1L, Assert.Single(result.NonConvergedEvaluations, pair => string.Equals(pair.Key, Beta, StringComparison.Ordinal)).Value);
    }

    /// <summary>Verifies a looser tolerance converges where the default does not, so the tolerance reaches the iteration.</summary>
    [Fact]
    public void TheToleranceDecidesConvergence()
    {
        var loose = Beta1(new MathBlockDomainOptions { IncompleteBetaTolerance = 1d });

        Assert.Empty(loose.NonConvergedEvaluations);
        Assert.True(loose.Outputs["result"].IsValid);
    }

    /// <summary>Verifies the elementwise form counts each non-converged row, and the rows are invalid under the Invalid policy.</summary>
    [Theory]
    [InlineData(MathBlockNonConvergencePolicy.Estimate)]
    [InlineData(MathBlockNonConvergencePolicy.Invalid)]
    public void TheElementwiseFormCountsEachRow(MathBlockNonConvergencePolicy policy)
    {
        var form = "elementwise.special.regularized-incomplete-beta@1";
        var sibling = "elementwise-valid.special.regularized-incomplete-beta@1";
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector(length: 3));
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var fill = builder.Input("fill", MathBlockType.Scalar());
        var program = builder
            .Output("values", builder.Apply("elementwise.special.regularized-incomplete-beta", 1, x, left, right, fill))
            .Output("valid", builder.Apply("elementwise-valid.special.regularized-incomplete-beta", 1, x, left, right))
            .Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["x"] = MathBlockValue.Vector([0.5d, 0.5d, 0.5d]),
            ["left"] = MathBlockValue.Scalar(Large),
            ["right"] = MathBlockValue.Scalar(Large),
            ["fill"] = MathBlockValue.Scalar(-1d)
        };

        var result = MathBlocksCoreCLRWorker.Create(new MathBlockDomainOptions { IncompleteBetaNonConvergence = policy })
            .ExecuteWithDiagnostics(program, inputs);

        Assert.Equal(3L, result.NonConvergedEvaluations[form]);
        Assert.Equal(3L, result.NonConvergedEvaluations[sibling]);
        var valid = result.Outputs["valid"].AsBooleanVector();
        Assert.All(Enumerable.Range(0, 3), row => Assert.Equal(policy == MathBlockNonConvergencePolicy.Estimate, valid[row]));
        Assert.All(
            Enumerable.Range(0, 3),
            row => Assert.Equal(
                policy == MathBlockNonConvergencePolicy.Estimate
                    ? MathBlockProbability.RegularizedIncompleteBeta(0.5d, Large, Large)
                    : -1d,
                result.Outputs["values"].AsVector()[row]));
    }

    private static MathBlockMatrix Dense(int size)
    {
        var values = new double[size * size];
        for (var row = 0; row < size; row++)
        {
            for (var column = row; column < size; column++)
            {
                var value = Math.Sin(1d + row * 7 + column * 3) + 2d;
                values[row * size + column] = value;
                values[column * size + row] = value;
            }
        }

        return new MathBlockMatrix(size, size, values);
    }

    private static MathBlockExecutionResult Jacobi(string identifier, MathBlockMatrix matrix, MathBlockDomainOptions options)
    {
        var scalar = string.Equals(identifier, "matrix.spectral-norm", StringComparison.Ordinal);
        var program = scalar
            ? Program(identifier, MathBlockType.Matrix(rows: matrix.Rows, columns: matrix.Columns), MathBlockType.Scalar())
            : Program(identifier, MathBlockType.Matrix(rows: matrix.Rows, columns: matrix.Columns));
        var inputs = scalar
            ? Named(MathBlockValue.Matrix(matrix), MathBlockValue.Scalar(10d))
            : Named(MathBlockValue.Matrix(matrix));
        return MathBlocksCoreCLRWorker.Create(options).ExecuteWithDiagnostics(program, inputs);
    }

    /// <summary>Verifies a Jacobi sweep that ends at its rotation budget with off-diagonal entries left is counted per operation.</summary>
    [Theory]
    [InlineData("matrix.symmetric-eigenvalues")]
    [InlineData("matrix.largest-symmetric-eigenvalue")]
    [InlineData("matrix.smallest-symmetric-eigenvalue")]
    [InlineData("matrix.spectral-norm")]
    public void JacobiCountsTheEvaluationThatEndsAtItsBudget(string identifier)
    {
        var estimate = Jacobi(identifier, Dense(6), new MathBlockDomainOptions { JacobiRotationMultiplier = 1 });
        var invalid = Jacobi(
            identifier,
            Dense(6),
            new MathBlockDomainOptions { JacobiRotationMultiplier = 1, JacobiNonConvergence = MathBlockNonConvergencePolicy.Invalid });

        Assert.True(estimate.Outputs["result"].IsValid);
        Assert.Equal(1L, Assert.Single(estimate.NonConvergedEvaluations, pair => string.Equals(pair.Key, identifier + "@1", StringComparison.Ordinal)).Value);
        Assert.False(invalid.Outputs["result"].IsValid);
        Assert.Equal(1L, Assert.Single(invalid.NonConvergedEvaluations, pair => string.Equals(pair.Key, identifier + "@1", StringComparison.Ordinal)).Value);
    }

    /// <summary>Verifies a matrix one rotation diagonalizes converges within the budget of one rotation per entry.</summary>
    [Fact]
    public void JacobiDoesNotCountAnEvaluationThatConverges()
    {
        var result = Jacobi("matrix.symmetric-eigenvalues", new MathBlockMatrix(2, 2, [2d, 1d, 1d, 2d]), new MathBlockDomainOptions { JacobiRotationMultiplier = 1 });

        Assert.Empty(result.NonConvergedEvaluations);
        Assert.Equal([1d, 3d], result.Outputs["result"].AsVector().Select(value => Math.Round(value, 12, MidpointRounding.ToEven)).ToArray());
    }

    /// <summary>Verifies the rotation budget is the multiplier times n times n, in 64 bits: a larger multiplier converges the matrix a small one does not.</summary>
    [Fact]
    public void ALargerRotationMultiplierConverges()
    {
        var small = Jacobi("matrix.symmetric-eigenvalues", Dense(6), new MathBlockDomainOptions { JacobiRotationMultiplier = 1 });
        var large = Jacobi("matrix.symmetric-eigenvalues", Dense(6), new MathBlockDomainOptions { JacobiRotationMultiplier = 1_000_000 });

        Assert.NotEmpty(small.NonConvergedEvaluations);
        Assert.Empty(large.NonConvergedEvaluations);
        Assert.True(large.Outputs["result"].IsValid);
    }

    /// <summary>Verifies the algebraic connectivity of a graph counts under its own identity.</summary>
    [Fact]
    public void TheAlgebraicConnectivityCountsItsJacobiEvaluation()
    {
        var edges = new List<MathBlockGraphEdge>();
        for (var from = 0; from < 6; from++)
        {
            for (var to = from + 1; to < 6; to++)
                edges.Add(new(from, to, 1d + (from * 7 + to * 3) % 5));
        }

        var program = Program("graph.algebraic-connectivity", MathBlockType.Graph());
        var graph = Named(MathBlockValue.Graph(new MathBlockGraph(6, edges)));

        var estimate = MathBlocksCoreCLRWorker.Create(new MathBlockDomainOptions { JacobiRotationMultiplier = 1 }).ExecuteWithDiagnostics(program, graph);
        var invalid = MathBlocksCoreCLRWorker.Create(new MathBlockDomainOptions { JacobiRotationMultiplier = 1, JacobiNonConvergence = MathBlockNonConvergencePolicy.Invalid }).ExecuteWithDiagnostics(program, graph);

        Assert.Equal(1L, estimate.NonConvergedEvaluations["graph.algebraic-connectivity@1"]);
        Assert.True(estimate.Outputs["result"].IsValid);
        Assert.False(invalid.Outputs["result"].IsValid);
    }

    /// <summary>Verifies an execution without a non-converged evaluation reports an empty dictionary, and the shared worker counts under the defaults.</summary>
    [Fact]
    public void ADefaultExecutionWithoutNonConvergenceReportsNothing()
    {
        var program = Program("special.regularized-incomplete-beta", MathBlockType.Scalar(), MathBlockType.Scalar(), MathBlockType.Scalar());

        var result = MathBlocksCoreCLRWorker.Shared.ExecuteWithDiagnostics(
            program,
            Named(MathBlockValue.Scalar(0.5d), MathBlockValue.Scalar(2d), MathBlockValue.Scalar(3d)));

        Assert.Empty(result.NonConvergedEvaluations);
        Assert.True(result.Outputs["result"].IsValid);
    }

    private static MathBlockOperation Operation(string identity) =>
        MathBlockCatalog.Standard.Get(identity[..identity.LastIndexOf('@')]);
}
