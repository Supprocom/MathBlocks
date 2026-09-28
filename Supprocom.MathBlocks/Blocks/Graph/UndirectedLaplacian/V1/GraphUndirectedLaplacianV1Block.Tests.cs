namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.undirected-laplacian@1</c> operation contract.</summary>
public sealed class GraphUndirectedLaplacianV1BlockTests
{
    /// <summary>Checks the <c>graph.undirected-laplacian@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.undirected-laplacian@1");
}
