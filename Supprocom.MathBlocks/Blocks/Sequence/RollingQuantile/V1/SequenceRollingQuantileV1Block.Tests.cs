namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceRollingQuantileV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-quantile@1");
}
