namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsLinearRSquaredV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.linear-r-squared@1");
}
