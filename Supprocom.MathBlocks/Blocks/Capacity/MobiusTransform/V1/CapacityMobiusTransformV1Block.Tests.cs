namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>capacity.mobius-transform@1</c> operation contract.</summary>
public sealed class CapacityMobiusTransformV1BlockTests
{
    /// <summary>Checks the <c>capacity.mobius-transform@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("capacity.mobius-transform@1");

    /// <summary>Checks that a set function whose length is not a power of two gives an invalid value of the declared type.</summary>
    [Fact]
    public void NonPowerOfTwoLengthIsInvalidWithTheDeclaredType()
    {
        var operation = MathBlockCatalog.Standard.Get("capacity.mobius-transform");
        var input = MathBlockValue.Vector([0d, 0.4d, 0.6d, 1d, 0.2d]);

        var result = operation.Evaluate(input);

        Assert.False(result.IsValid);
        Assert.Equal(operation.ResolveOutputType([input.Type]), result.Type);
        Assert.Equal(5, result.Type.Rows);
    }
}
