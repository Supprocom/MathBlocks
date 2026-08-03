namespace Supprocom.MathBlocks.Tests;

public sealed class GraphFromDirectedAdjacencyV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.from-directed-adjacency@1");
}
