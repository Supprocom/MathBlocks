namespace Supprocom.MathBlocks.Tests;

public sealed class GraphToDirectedAdjacencyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.to-directed-adjacency@1");
}
