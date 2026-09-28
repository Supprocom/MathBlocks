namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.undirected-adjacency-matrix@1</c> operation contract.</summary>
public sealed class GraphUndirectedAdjacencyMatrixV1BlockTests
{
    /// <summary>Checks the <c>graph.undirected-adjacency-matrix@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.undirected-adjacency-matrix@1");
}
