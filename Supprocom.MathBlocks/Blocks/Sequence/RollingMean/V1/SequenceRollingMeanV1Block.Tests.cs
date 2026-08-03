namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceRollingMeanV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-mean@1");
}
