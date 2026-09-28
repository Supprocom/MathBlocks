namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.smallest-symmetric-eigenvalue@1</c> operation contract.</summary>
public sealed class MatrixSmallestSymmetricEigenvalueV1BlockTests
{
    /// <summary>Checks the <c>matrix.smallest-symmetric-eigenvalue@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.smallest-symmetric-eigenvalue@1");
}
