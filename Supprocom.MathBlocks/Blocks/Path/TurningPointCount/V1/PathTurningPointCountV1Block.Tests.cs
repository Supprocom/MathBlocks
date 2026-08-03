namespace Supprocom.MathBlocks.Tests;

public sealed class PathTurningPointCountV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.turning-point-count@1");
}
