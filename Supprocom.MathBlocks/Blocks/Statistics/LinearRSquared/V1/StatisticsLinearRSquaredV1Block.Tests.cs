namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.linear-r-squared@1</c> operation contract.</summary>
public sealed class StatisticsLinearRSquaredV1BlockTests
{
    /// <summary>Checks the <c>statistics.linear-r-squared@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.linear-r-squared@1");
}
