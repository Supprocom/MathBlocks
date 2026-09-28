namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.population-covariance@1</c> operation contract.</summary>
public sealed class StatisticsPopulationCovarianceV1BlockTests
{
    /// <summary>Checks the <c>statistics.population-covariance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.population-covariance@1");
}
