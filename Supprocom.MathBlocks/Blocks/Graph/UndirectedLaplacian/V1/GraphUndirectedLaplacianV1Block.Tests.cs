namespace Supprocom.MathBlocks.Tests;

public sealed class GraphUndirectedLaplacianV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.undirected-laplacian@1");
}
