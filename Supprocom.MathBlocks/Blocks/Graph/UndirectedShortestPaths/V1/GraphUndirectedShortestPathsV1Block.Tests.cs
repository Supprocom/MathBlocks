namespace Supprocom.MathBlocks.Tests;

public sealed class GraphUndirectedShortestPathsV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.undirected-shortest-paths@1");
}
