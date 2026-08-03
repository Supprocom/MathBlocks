namespace Supprocom.MathBlocks.Tests;

public sealed class PathSignatureLevelThreeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.signature-level-three@1");
}
