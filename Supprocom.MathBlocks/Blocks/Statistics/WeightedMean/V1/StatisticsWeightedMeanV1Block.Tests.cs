namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsWeightedMeanV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.weighted-mean@1");
}
