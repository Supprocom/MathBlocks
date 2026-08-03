namespace Supprocom.MathBlocks.Tests;

public sealed class GraphHodgePotentialV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.hodge-potential@1");
}
