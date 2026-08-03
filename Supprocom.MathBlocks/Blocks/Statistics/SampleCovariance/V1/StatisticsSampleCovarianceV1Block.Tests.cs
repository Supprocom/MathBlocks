namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsSampleCovarianceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.sample-covariance@1");
}
