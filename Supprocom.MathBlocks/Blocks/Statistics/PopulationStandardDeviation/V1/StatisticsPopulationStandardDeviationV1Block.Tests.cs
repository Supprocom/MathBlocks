namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.population-standard-deviation@1</c> operation contract.</summary>
public sealed class StatisticsPopulationStandardDeviationV1BlockTests
{
    /// <summary>Checks the <c>statistics.population-standard-deviation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.population-standard-deviation@1");
}
