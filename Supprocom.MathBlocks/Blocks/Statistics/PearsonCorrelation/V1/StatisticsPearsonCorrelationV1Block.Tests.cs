namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsPearsonCorrelationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.pearson-correlation@1");
}
