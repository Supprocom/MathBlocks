namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.maximal-minors@1</c> operation contract.</summary>
public sealed class MatrixMaximalMinorsV1BlockTests
{
    /// <summary>Checks the <c>matrix.maximal-minors@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.maximal-minors@1");
}
