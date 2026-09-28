namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.subtract@1</c> operation contract.</summary>
public sealed class MatrixSubtractV1BlockTests
{
    /// <summary>Checks the <c>matrix.subtract@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.subtract@1");
}
