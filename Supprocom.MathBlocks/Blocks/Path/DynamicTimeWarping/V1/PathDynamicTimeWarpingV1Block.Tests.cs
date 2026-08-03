namespace Supprocom.MathBlocks.Tests;

public sealed class PathDynamicTimeWarpingV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.dynamic-time-warping@1");
}
