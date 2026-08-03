namespace Supprocom.MathBlocks.Tests;

public sealed class InformationTsallisEntropyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("information.tsallis-entropy@1");
}
