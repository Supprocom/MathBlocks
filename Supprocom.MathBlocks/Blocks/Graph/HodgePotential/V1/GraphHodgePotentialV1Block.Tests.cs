namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.hodge-potential@1</c> operation contract.</summary>
public sealed class GraphHodgePotentialV1BlockTests
{
    /// <summary>Checks the <c>graph.hodge-potential@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.hodge-potential@1");
}
