namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.theil-sen-slope@1</c> operation contract.</summary>
public sealed class StatisticsTheilSenSlopeV1BlockTests
{
    /// <summary>Checks the <c>statistics.theil-sen-slope@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.theil-sen-slope@1");
}
