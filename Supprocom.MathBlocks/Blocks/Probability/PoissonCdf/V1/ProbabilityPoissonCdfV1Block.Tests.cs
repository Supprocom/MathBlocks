namespace Supprocom.MathBlocks.Tests;

public sealed class ProbabilityPoissonCdfV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("probability.poisson-cdf@1");
}
