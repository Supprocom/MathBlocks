namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.pearson-correlation@1</c> operation contract.</summary>
public sealed class StatisticsPearsonCorrelationV1BlockTests
{
    /// <summary>Checks the <c>statistics.pearson-correlation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.pearson-correlation@1");
}
