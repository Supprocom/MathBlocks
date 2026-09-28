namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.flatten@1</c> operation contract.</summary>
public sealed class MatrixFlattenV1BlockTests
{
    /// <summary>Checks the <c>matrix.flatten@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.flatten@1");
}
