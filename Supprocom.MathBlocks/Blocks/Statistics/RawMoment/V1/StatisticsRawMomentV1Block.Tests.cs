namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsRawMomentV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.raw-moment@1");
}
