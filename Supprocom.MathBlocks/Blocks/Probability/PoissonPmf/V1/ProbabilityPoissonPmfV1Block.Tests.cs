namespace Supprocom.MathBlocks.Tests;

public sealed class ProbabilityPoissonPmfV1BlockTests
{
    [Fact]
    [Trait("Category", "BlockContract")]
    public void Contract_is_valid() => MathBlockFeatureContractAssertions.Verify("probability.poisson-pmf@1");
}
