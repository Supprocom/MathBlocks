namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceRollingMedianV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-median@1");
}
