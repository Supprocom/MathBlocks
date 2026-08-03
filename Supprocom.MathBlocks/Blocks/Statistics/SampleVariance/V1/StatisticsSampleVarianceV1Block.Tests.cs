namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsSampleVarianceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.sample-variance@1");
}
