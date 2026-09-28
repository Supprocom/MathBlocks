namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.covariance-matrix@1</c> operation contract.</summary>
public sealed class StatisticsCovarianceMatrixV1BlockTests
{
    /// <summary>Checks the <c>statistics.covariance-matrix@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.covariance-matrix@1");
}
