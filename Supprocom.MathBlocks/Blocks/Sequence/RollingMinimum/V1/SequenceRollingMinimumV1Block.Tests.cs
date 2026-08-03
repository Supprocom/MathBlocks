namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceRollingMinimumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-minimum@1");
}
