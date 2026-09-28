namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.algebraic-connectivity@1</c> operation contract.</summary>
public sealed class GraphAlgebraicConnectivityV1BlockTests
{
    /// <summary>Checks the <c>graph.algebraic-connectivity@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.algebraic-connectivity@1");
}
