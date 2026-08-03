namespace Supprocom.MathBlocks.Tests;

public sealed class PathMaximumDeclineV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.maximum-decline@1");
}
