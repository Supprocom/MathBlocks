namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceExponentialMovingAverageV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.exponential-moving-average@1");
}
