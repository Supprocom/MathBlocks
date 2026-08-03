namespace Supprocom.MathBlocks.Tests;

public sealed class SequenceDifferenceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("sequence.difference@1");
}
