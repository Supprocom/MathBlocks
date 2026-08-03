namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsAutocorrelationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.autocorrelation@1");
}
