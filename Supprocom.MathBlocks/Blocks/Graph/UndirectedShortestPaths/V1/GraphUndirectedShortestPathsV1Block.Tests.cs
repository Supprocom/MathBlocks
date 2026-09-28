namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.undirected-shortest-paths@1</c> operation contract.</summary>
public sealed class GraphUndirectedShortestPathsV1BlockTests
{
    /// <summary>Checks the <c>graph.undirected-shortest-paths@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.undirected-shortest-paths@1");
}
