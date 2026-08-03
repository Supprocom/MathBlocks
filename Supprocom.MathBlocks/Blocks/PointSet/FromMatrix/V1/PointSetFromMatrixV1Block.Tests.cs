namespace Supprocom.MathBlocks.Tests;

public sealed class PointSetFromMatrixV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("point-set.from-matrix@1");
}
