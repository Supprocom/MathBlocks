namespace Supprocom.MathBlocks.Tests;

public sealed class GraphIsConnectedV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.is-connected@1");
}
