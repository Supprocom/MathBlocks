namespace Supprocom.MathBlocks.Tests;

public sealed class PathMaximumRelativeDeclineV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.maximum-relative-decline@1");
}
