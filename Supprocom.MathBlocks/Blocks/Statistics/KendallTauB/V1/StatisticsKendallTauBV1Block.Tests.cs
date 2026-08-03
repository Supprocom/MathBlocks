namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsKendallTauBV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.kendall-tau-b@1");
}
