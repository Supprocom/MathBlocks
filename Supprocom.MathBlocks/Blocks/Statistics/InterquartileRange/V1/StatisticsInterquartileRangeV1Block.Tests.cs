namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsInterquartileRangeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.interquartile-range@1");
}
