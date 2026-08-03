namespace Supprocom.MathBlocks.Tests;

public sealed class GraphUndirectedAdjacencyMatrixV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.undirected-adjacency-matrix@1");
}
