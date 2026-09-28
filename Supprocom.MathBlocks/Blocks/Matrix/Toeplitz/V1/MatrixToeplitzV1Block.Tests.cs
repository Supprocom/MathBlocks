namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.toeplitz@1</c> operation contract.</summary>
public sealed class MatrixToeplitzV1BlockTests
{
    /// <summary>Checks the <c>matrix.toeplitz@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.toeplitz@1");
}
