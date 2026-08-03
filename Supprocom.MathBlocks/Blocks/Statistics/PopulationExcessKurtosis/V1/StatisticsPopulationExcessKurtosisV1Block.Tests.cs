namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsPopulationExcessKurtosisV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.population-excess-kurtosis@1");
}
