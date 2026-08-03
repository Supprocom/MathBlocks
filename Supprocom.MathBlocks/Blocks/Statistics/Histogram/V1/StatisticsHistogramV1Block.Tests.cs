namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsHistogramV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.histogram@1");
}
