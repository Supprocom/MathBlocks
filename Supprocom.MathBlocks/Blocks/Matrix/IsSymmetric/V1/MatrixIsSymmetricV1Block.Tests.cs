namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.is-symmetric@1</c> operation contract.</summary>
public sealed class MatrixIsSymmetricV1BlockTests
{
    /// <summary>Checks the <c>matrix.is-symmetric@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.is-symmetric@1");
}
