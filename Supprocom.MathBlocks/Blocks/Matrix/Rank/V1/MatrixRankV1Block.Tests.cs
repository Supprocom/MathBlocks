namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>matrix.rank@1</c> operation contract.</summary>
public sealed class MatrixRankV1BlockTests
{
    /// <summary>Checks the <c>matrix.rank@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("matrix.rank@1");
}
