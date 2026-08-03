namespace Supprocom.MathBlocks.Tests;

public sealed class PathTotalVariationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.total-variation@1");
}
