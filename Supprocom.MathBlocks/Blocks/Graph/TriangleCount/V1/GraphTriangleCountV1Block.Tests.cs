namespace Supprocom.MathBlocks.Tests;

public sealed class GraphTriangleCountV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.triangle-count@1");
}
