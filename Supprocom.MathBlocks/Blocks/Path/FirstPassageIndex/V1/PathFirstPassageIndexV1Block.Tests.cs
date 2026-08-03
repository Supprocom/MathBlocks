namespace Supprocom.MathBlocks.Tests;

public sealed class PathFirstPassageIndexV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.first-passage-index@1");
}
