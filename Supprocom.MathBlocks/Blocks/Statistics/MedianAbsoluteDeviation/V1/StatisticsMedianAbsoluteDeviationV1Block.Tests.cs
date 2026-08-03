namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsMedianAbsoluteDeviationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.median-absolute-deviation@1");
}
