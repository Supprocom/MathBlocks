namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsRootMeanSquareV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.root-mean-square@1");
}
