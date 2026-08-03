namespace Supprocom.MathBlocks.Tests;

public sealed class PathLeadLagTransformV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.lead-lag-transform@1");
}
