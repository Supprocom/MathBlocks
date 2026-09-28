namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.root-mean-square@1</c> operation contract.</summary>
public sealed class StatisticsRootMeanSquareV1BlockTests
{
    /// <summary>Checks the <c>statistics.root-mean-square@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.root-mean-square@1");
}
