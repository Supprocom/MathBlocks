namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex-matrix.pick@1</c> operation contract.</summary>
public sealed class ComplexMatrixPickV1BlockTests
{
    /// <summary>Checks the <c>complex-matrix.pick@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex-matrix.pick@1");

    /// <summary>Checks that nodes outside the open unit disk give an invalid value of the declared type.</summary>
    [Fact]
    public void NodesOutsideTheUnitDiskAreInvalidWithTheDeclaredType()
    {
        var operation = MathBlockCatalog.Standard.Get("complex-matrix.pick");
        var nodes = MathBlockValue.ComplexVector(
            [new Complex(1f, 0f), new Complex(0f, 0f), new Complex(0.1f, 0f), new Complex(0.2f, 0f), new Complex(0.3f, 0f)]);
        var values = MathBlockValue.ComplexVector(
            [new Complex(0f, 0f), new Complex(0f, 0f), new Complex(0f, 0f), new Complex(0f, 0f), new Complex(0f, 0f)]);

        var result = operation.Evaluate(nodes, values);

        Assert.False(result.IsValid);
        Assert.Equal(operation.ResolveOutputType([nodes.Type, values.Type]), result.Type);
        Assert.Equal(5, result.Type.Rows);
        Assert.Equal(5, result.Type.Columns);
    }
}
