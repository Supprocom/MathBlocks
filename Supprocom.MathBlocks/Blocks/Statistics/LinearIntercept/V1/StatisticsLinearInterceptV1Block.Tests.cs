namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.linear-intercept@1</c> operation contract.</summary>
public sealed class StatisticsLinearInterceptV1BlockTests
{
    /// <summary>Checks the <c>statistics.linear-intercept@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.linear-intercept@1");
}
