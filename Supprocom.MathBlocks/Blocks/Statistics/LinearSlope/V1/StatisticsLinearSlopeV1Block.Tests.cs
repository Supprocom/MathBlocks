namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsLinearSlopeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.linear-slope@1");
}
