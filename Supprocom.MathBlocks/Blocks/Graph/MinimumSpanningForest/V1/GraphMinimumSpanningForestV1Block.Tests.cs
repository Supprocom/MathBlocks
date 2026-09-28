namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.minimum-spanning-forest@1</c> operation contract.</summary>
public sealed class GraphMinimumSpanningForestV1BlockTests
{
    /// <summary>Checks the <c>graph.minimum-spanning-forest@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.minimum-spanning-forest@1");
}
