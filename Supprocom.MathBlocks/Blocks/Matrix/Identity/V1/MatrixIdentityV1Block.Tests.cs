namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.identity@1</c> operation contract.</summary>
public sealed class MatrixIdentityV1BlockTests
{
    /// <summary>Checks the <c>matrix.identity@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.identity@1");
}
