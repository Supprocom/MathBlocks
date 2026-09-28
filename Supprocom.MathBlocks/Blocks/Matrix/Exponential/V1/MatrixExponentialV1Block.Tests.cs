namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.exponential@1</c> operation contract.</summary>
public sealed class MatrixExponentialV1BlockTests
{
    /// <summary>Checks the <c>matrix.exponential@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.exponential@1");
}
