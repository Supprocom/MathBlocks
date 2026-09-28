namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.diagonal@1</c> operation contract.</summary>
public sealed class MatrixDiagonalV1BlockTests
{
    /// <summary>Checks the <c>matrix.diagonal@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.diagonal@1");
}
