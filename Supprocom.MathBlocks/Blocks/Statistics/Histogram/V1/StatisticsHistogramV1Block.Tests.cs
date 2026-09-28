namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.histogram@1</c> operation contract.</summary>
public sealed class StatisticsHistogramV1BlockTests
{
    /// <summary>Checks the <c>statistics.histogram@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.histogram@1");
}
