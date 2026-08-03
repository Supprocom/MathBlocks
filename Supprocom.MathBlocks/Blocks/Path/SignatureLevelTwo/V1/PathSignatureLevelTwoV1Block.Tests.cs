namespace Supprocom.MathBlocks.Tests;

public sealed class PathSignatureLevelTwoV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.signature-level-two@1");
}
