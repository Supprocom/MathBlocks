namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsPopulationSkewnessV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.population-skewness@1");
}
