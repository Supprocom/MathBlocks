namespace Supprocom.MathBlocks.Tests;

public sealed class GraphWeightedDegreeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.weighted-degree@1");
}
