namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.connected-component-count@1</c> operation contract.</summary>
public sealed class GraphConnectedComponentCountV1BlockTests
{
    /// <summary>Checks the <c>graph.connected-component-count@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.connected-component-count@1");
}
