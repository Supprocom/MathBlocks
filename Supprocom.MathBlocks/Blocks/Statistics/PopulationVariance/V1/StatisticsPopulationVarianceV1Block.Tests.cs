namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.population-variance@1</c> operation contract.</summary>
public sealed class StatisticsPopulationVarianceV1BlockTests
{
    /// <summary>Checks the <c>statistics.population-variance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.population-variance@1");
}
