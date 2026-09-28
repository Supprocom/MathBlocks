namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.population-skewness@1</c> operation contract.</summary>
public sealed class StatisticsPopulationSkewnessV1BlockTests
{
    /// <summary>Checks the <c>statistics.population-skewness@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.population-skewness@1");
}
