namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>probability.poisson-pmf@1</c> operation contract.</summary>
public sealed class ProbabilityPoissonPmfV1BlockTests
{
    /// <summary>Checks the <c>probability.poisson-pmf@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("probability.poisson-pmf@1");
}
