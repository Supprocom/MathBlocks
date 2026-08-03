namespace Supprocom.MathBlocks.Tests;

public sealed class PointSetToMatrixV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("point-set.to-matrix@1");
}
