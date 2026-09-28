namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>markov.stationary-distribution@1</c> operation contract.</summary>
public sealed class MarkovStationaryDistributionV1BlockTests
{
    /// <summary>Checks the <c>markov.stationary-distribution@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("markov.stationary-distribution@1");
}
