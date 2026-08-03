namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsWeightedPopulationVarianceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.weighted-population-variance@1");
}
