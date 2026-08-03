namespace Supprocom.MathBlocks.Tests;

public sealed class GraphDegreeV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.degree@1");
}
