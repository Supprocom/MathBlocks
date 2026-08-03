namespace Supprocom.MathBlocks.Tests;

public sealed class GraphMinimumSpanningForestV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("graph.minimum-spanning-forest@1");
}
