namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.commutator@1</c> operation contract.</summary>
public sealed class MatrixCommutatorV1BlockTests
{
    /// <summary>Checks the <c>matrix.commutator@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.commutator@1");
}
