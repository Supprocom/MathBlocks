namespace Supprocom.MathBlocks.Tests;

public sealed class PathReflectedCumulativeSumV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("path.reflected-cumulative-sum@1");
}
