namespace Supprocom.MathBlocks.Tests;

public sealed class PathCumulativeDeviationV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.cumulative-deviation@1");
}
