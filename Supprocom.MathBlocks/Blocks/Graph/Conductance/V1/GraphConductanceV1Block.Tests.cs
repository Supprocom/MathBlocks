namespace Supprocom.MathBlocks.Tests;

public sealed class GraphConductanceV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.conductance@1");
}
