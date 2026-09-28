namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.raw-moment@1</c> operation contract.</summary>
public sealed class StatisticsRawMomentV1BlockTests
{
    /// <summary>Checks the <c>statistics.raw-moment@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.raw-moment@1");
}
