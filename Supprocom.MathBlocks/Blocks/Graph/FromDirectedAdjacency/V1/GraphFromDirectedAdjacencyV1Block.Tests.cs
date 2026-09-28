namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.from-directed-adjacency@1</c> operation contract.</summary>
public sealed class GraphFromDirectedAdjacencyV1BlockTests
{
    /// <summary>Checks the <c>graph.from-directed-adjacency@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.from-directed-adjacency@1");
}
