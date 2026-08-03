namespace Supprocom.MathBlocks.Tests;

public sealed class InformationCrossEntropyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.cross-entropy@1");
}
