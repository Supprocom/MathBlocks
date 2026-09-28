namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.sample-covariance@1</c> operation contract.</summary>
public sealed class StatisticsSampleCovarianceV1BlockTests
{
    /// <summary>Checks the <c>statistics.sample-covariance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.sample-covariance@1");
}
