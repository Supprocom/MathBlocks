namespace Supprocom.MathBlocks.Tests;

public sealed class StatisticsCovarianceMatrixV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("statistics.covariance-matrix@1");
}
