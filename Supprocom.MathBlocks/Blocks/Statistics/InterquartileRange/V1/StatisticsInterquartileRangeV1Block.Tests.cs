namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.interquartile-range@1</c> operation contract.</summary>
public sealed class StatisticsInterquartileRangeV1BlockTests
{
    /// <summary>Checks the <c>statistics.interquartile-range@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.interquartile-range@1");
}
