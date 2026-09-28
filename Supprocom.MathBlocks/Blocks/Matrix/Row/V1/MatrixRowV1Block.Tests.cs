namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.row@1</c> operation contract.</summary>
public sealed class MatrixRowV1BlockTests
{
    /// <summary>Checks the <c>matrix.row@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.row@1");
}
