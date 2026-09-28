namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.weighted-degree@1</c> operation contract.</summary>
public sealed class GraphWeightedDegreeV1BlockTests
{
    /// <summary>Checks the <c>graph.weighted-degree@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.weighted-degree@1");
}
