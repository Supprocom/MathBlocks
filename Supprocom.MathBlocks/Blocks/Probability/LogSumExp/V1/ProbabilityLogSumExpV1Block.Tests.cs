namespace Supprocom.MathBlocks.Tests;

public sealed class ProbabilityLogSumExpV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("probability.log-sum-exp@1");
}
