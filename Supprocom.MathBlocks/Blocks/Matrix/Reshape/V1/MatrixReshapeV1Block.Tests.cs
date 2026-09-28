namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.reshape@1</c> operation contract.</summary>
public sealed class MatrixReshapeV1BlockTests
{
    /// <summary>Checks the <c>matrix.reshape@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.reshape@1");
}
