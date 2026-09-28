namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>probability.poisson-cdf@1</c> operation contract.</summary>
public sealed class ProbabilityPoissonCdfV1BlockTests
{
    /// <summary>Checks the <c>probability.poisson-cdf@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("probability.poisson-cdf@1");
}
