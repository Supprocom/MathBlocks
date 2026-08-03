namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceRollingSumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-sum@1");
}
