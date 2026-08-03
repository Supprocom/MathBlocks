namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsSpearmanCorrelationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.spearman-correlation@1");
}
