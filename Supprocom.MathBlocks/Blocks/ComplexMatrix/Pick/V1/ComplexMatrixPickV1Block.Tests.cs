namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex-matrix.pick@1</c> operation contract.</summary>
public sealed class ComplexMatrixPickV1BlockTests
{
    /// <summary>Checks the <c>complex-matrix.pick@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex-matrix.pick@1");
}
