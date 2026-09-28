namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>graph.hodge-residual-norm@1</c> operation contract.</summary>
public sealed class GraphHodgeResidualNormV1BlockTests
{
    /// <summary>Checks the <c>graph.hodge-residual-norm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("graph.hodge-residual-norm@1");
}
