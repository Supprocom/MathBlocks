namespace Supprocom.MathBlocks.Tests;

public sealed class InformationShannonEntropyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.shannon-entropy@1");
}
