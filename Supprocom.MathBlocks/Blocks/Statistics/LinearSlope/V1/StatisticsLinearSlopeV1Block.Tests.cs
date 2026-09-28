namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.linear-slope@1</c> operation contract.</summary>
public sealed class StatisticsLinearSlopeV1BlockTests
{
    /// <summary>Checks the <c>statistics.linear-slope@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.linear-slope@1");
}
