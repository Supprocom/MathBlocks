namespace Supprocom.MathBlocks.Tests;

public sealed class InformationBinaryShannonEntropyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.binary-shannon-entropy@1");
}
