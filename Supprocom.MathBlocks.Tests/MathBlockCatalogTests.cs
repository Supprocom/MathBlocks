using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockCatalogTests
{
    [Fact]
    public void Every_registered_operation_has_regression_and_performance_evidence()
    {
        var operations = MathBlockCatalog.Standard.Operations;
        Assert.True(operations.Count >= 337, $"Only {operations.Count} operations are registered.");
        Assert.All(operations, operation =>
        {
            Assert.NotEmpty(operation.RegressionCases);
            Assert.NotEmpty(operation.PerformanceCase.Inputs);
            Assert.True(operation.PerformanceCase.Iterations > 0);
            Assert.InRange(operation.PerformanceCase.MaximumWarmLatencyMicroseconds, double.Epsilon, 1_000d);
            Assert.Equal(operation.Arity, operation.PerformanceCase.Inputs.Count);
        });
        Assert.Equal(
            operations.Count,
            operations.Select(operation => operation.Identity).Distinct(StringComparer.Ordinal).Count());
    }

    [Fact]
    public void Every_registered_operation_is_deterministic_and_preserves_inputs()
    {
        var failures = new List<string>();
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            var inputs = operation.PerformanceCase.Inputs.ToArray();
            var copies = inputs.Select(Clone).ToArray();
            try
            {
                var first = operation.Evaluate(inputs);
                var second = operation.Evaluate(inputs);
                if (!first.ApproximatelyEquals(second, 1e-12))
                    failures.Add($"{operation.Identity}: repeated outputs differ");
                for (var index = 0; index < inputs.Length; index++)
                    if (!inputs[index].ApproximatelyEquals(copies[index], 0d))
                        failures.Add($"{operation.Identity}: input {index} changed");
            }
            catch (Exception exception)
            {
                failures.Add($"{operation.Identity}: {exception.GetType().Name}: {exception.Message}");
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures));
    }

    [Fact]
    public void Catalog_contains_each_required_mathematical_family()
    {
        var prefixes = MathBlockCatalog.Standard.Operations
            .Select(operation => operation.Identifier.Split('.')[0])
            .ToHashSet(StringComparer.Ordinal);
        foreach (var required in new[]
                 {
                     "scalar", "boolean", "boolean-vector", "complex", "complex-vector", "vector", "sequence",
                     "statistics", "probability", "information", "combinatorics", "special", "matrix", "polynomial",
                     "geometry", "topology", "graph", "transport", "path", "state", "transform", "point-set",
                     "tropical", "order", "shape", "extension", "inequality", "projective", "survival",
                     "cooperative", "capacity", "markov"
                 })
        {
            Assert.Contains(required, prefixes);
        }
    }

    private static MathBlockValue Clone(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Scalar => MathBlockValue.Scalar(value.AsScalar(), value.Type.Unit),
        MathBlockValueKind.Boolean => MathBlockValue.Boolean(value.AsBoolean()),
        MathBlockValueKind.Complex => MathBlockValue.Complex(value.AsComplex(), value.Type.Unit),
        MathBlockValueKind.Vector => MathBlockValue.Vector(value.AsVector().ToArray(), value.Type.Unit),
        MathBlockValueKind.BooleanVector => MathBlockValue.BooleanVector(value.AsBooleanVector().ToArray()),
        MathBlockValueKind.Matrix => MathBlockValue.Matrix(new MathBlockMatrix(
            value.AsMatrix().Rows, value.AsMatrix().Columns, value.AsMatrix().ToArray()), value.Type.Unit),
        MathBlockValueKind.ComplexVector => MathBlockValue.ComplexVector(value.AsComplexVector().ToArray(), value.Type.Unit),
        MathBlockValueKind.ComplexMatrix => MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(
            value.AsComplexMatrix().Rows, value.AsComplexMatrix().Columns, value.AsComplexMatrix().ToArray()), value.Type.Unit),
        MathBlockValueKind.PointSet => MathBlockValue.PointSet(new MathBlockPointSet(value.AsPointSet().ToArray()), value.Type.Unit),
        MathBlockValueKind.Graph => MathBlockValue.Graph(new MathBlockGraph(
            value.AsGraph().VertexCount, value.AsGraph().ToArray()), value.Type.Unit),
        MathBlockValueKind.RunSet => MathBlockValue.RunSet(new MathBlockRunSet(value.AsRunSet().ToArray()), value.Type.Unit),
        _ => throw new InvalidOperationException($"Unsupported value kind '{value.Type.Kind}'.")
    };
}
