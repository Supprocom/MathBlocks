namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceRollingVarianceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-variance@1");
}
