namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.central-moment@1</c> operation contract.</summary>
public sealed class StatisticsCentralMomentV1BlockTests
{
    /// <summary>Checks the <c>statistics.central-moment@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.central-moment@1");
}
