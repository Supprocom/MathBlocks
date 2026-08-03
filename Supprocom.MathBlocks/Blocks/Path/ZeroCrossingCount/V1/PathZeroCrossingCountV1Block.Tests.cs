namespace Supprocom.MathBlocks.Tests;

public sealed class PathZeroCrossingCountV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.zero-crossing-count@1");
}
