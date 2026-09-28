namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.symmetric-eigenvalues@1</c> operation contract.</summary>
public sealed class MatrixSymmetricEigenvaluesV1BlockTests
{
    /// <summary>Checks the <c>matrix.symmetric-eigenvalues@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.symmetric-eigenvalues@1");
}
