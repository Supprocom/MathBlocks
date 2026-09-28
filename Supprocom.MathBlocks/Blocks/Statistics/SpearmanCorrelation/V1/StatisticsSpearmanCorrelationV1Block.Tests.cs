namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.spearman-correlation@1</c> operation contract.</summary>
public sealed class StatisticsSpearmanCorrelationV1BlockTests
{
    /// <summary>Checks the <c>statistics.spearman-correlation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.spearman-correlation@1");
}
