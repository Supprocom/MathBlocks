namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>point-set.from-matrix@1</c> operation contract.</summary>
public sealed class PointSetFromMatrixV1BlockTests
{
    /// <summary>Checks the <c>point-set.from-matrix@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("point-set.from-matrix@1");
}
