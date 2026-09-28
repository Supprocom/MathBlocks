namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.median-absolute-deviation@1</c> operation contract.</summary>
public sealed class StatisticsMedianAbsoluteDeviationV1BlockTests
{
    /// <summary>Checks the <c>statistics.median-absolute-deviation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.median-absolute-deviation@1");
}
