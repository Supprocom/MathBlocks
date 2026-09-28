namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>probability.normal-cdf@1</c> operation contract.</summary>
public sealed class ProbabilityNormalCdfV1BlockTests
{
    /// <summary>Checks the <c>probability.normal-cdf@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("probability.normal-cdf@1");
}
