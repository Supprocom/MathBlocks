namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsSampleStandardDeviationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.sample-standard-deviation@1");
}
