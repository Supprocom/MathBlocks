namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.pseudomedian@1</c> operation contract.</summary>
public sealed class StatisticsPseudomedianV1BlockTests
{
    /// <summary>Checks the <c>statistics.pseudomedian@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.pseudomedian@1");
}
