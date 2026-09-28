namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.kendall-tau-b@1</c> operation contract.</summary>
public sealed class StatisticsKendallTauBV1BlockTests
{
    /// <summary>Checks the <c>statistics.kendall-tau-b@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.kendall-tau-b@1");
}
