namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsPopulationVarianceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.population-variance@1");
}
