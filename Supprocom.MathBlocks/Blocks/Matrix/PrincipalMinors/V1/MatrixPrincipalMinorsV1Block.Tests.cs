namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.principal-minors@1</c> operation contract.</summary>
public sealed class MatrixPrincipalMinorsV1BlockTests
{
    /// <summary>Checks the <c>matrix.principal-minors@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.principal-minors@1");
}
