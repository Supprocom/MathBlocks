namespace Supprocom.MathBlocks.Tests;

public sealed class GraphHodgeResidualNormV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.hodge-residual-norm@1");
}
