namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.multiply-vector@1</c> operation contract.</summary>
public sealed class MatrixMultiplyVectorV1BlockTests
{
    /// <summary>Checks the <c>matrix.multiply-vector@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.multiply-vector@1");
}
