namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.sample-standard-deviation@1</c> operation contract.</summary>
public sealed class StatisticsSampleStandardDeviationV1BlockTests
{
    /// <summary>Checks the <c>statistics.sample-standard-deviation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.sample-standard-deviation@1");
}
