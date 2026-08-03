namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsLinearInterceptV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.linear-intercept@1");
}
