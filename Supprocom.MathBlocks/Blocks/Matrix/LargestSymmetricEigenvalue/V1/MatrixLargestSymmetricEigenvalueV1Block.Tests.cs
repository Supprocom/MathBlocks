namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.largest-symmetric-eigenvalue@1</c> operation contract.</summary>
public sealed class MatrixLargestSymmetricEigenvalueV1BlockTests
{
    /// <summary>Checks the <c>matrix.largest-symmetric-eigenvalue@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.largest-symmetric-eigenvalue@1");
}
