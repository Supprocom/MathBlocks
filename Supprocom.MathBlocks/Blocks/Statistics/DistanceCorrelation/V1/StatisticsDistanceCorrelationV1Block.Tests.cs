namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsDistanceCorrelationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.distance-correlation@1");
}
