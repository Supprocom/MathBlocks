namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsPopulationCovarianceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.population-covariance@1");
}
