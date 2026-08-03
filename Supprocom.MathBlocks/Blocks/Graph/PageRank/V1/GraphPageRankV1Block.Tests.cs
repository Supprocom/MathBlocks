namespace Supprocom.MathBlocks.Tests;

public sealed class GraphPageRankV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.page-rank@1");
}
