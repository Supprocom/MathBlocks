namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.degree@1</c> operation contract.</summary>
public sealed class GraphDegreeV1BlockTests
{
    /// <summary>Checks the <c>graph.degree@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.degree@1");
}
