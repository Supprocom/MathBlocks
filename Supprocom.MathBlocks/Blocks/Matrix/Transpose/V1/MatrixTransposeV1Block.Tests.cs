namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.transpose@1</c> operation contract.</summary>
public sealed class MatrixTransposeV1BlockTests
{
    /// <summary>Checks the <c>matrix.transpose@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.transpose@1");
}
