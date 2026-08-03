namespace Supprocom.MathBlocks.Tests;

public sealed class ExtensionWhitneyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("extension.whitney@1");
}
