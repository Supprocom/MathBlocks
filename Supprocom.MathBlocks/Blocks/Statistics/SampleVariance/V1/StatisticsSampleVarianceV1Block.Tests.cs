namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.sample-variance@1</c> operation contract.</summary>
public sealed class StatisticsSampleVarianceV1BlockTests
{
    /// <summary>Checks the <c>statistics.sample-variance@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.sample-variance@1");
}
