namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsCentralMomentV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.central-moment@1");
}
