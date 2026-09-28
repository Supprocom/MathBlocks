namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.weighted-mean@1</c> operation contract.</summary>
public sealed class StatisticsWeightedMeanV1BlockTests
{
    /// <summary>Checks the <c>statistics.weighted-mean@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.weighted-mean@1");
}
