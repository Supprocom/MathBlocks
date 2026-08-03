namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceRollingMaximumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-maximum@1");
}
