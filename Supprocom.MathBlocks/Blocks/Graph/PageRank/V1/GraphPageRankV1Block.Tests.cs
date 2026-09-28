namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.page-rank@1</c> operation contract.</summary>
public sealed class GraphPageRankV1BlockTests
{
    /// <summary>Checks the <c>graph.page-rank@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.page-rank@1");
}
