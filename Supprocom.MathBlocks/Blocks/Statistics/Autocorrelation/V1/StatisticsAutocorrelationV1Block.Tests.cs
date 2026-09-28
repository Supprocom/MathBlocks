namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.autocorrelation@1</c> operation contract.</summary>
public sealed class StatisticsAutocorrelationV1BlockTests
{
    /// <summary>Checks the <c>statistics.autocorrelation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.autocorrelation@1");
}
