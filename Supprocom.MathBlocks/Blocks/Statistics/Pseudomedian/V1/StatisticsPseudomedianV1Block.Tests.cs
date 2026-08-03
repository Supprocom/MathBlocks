namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsPseudomedianV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.pseudomedian@1");
}
