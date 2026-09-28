namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.population-excess-kurtosis@1</c> operation contract.</summary>
public sealed class StatisticsPopulationExcessKurtosisV1BlockTests
{
    /// <summary>Checks the <c>statistics.population-excess-kurtosis@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.population-excess-kurtosis@1");
}
