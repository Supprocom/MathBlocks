namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>statistics.distance-correlation@1</c> operation contract.</summary>
public sealed class StatisticsDistanceCorrelationV1BlockTests
{
    /// <summary>Checks the <c>statistics.distance-correlation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("statistics.distance-correlation@1");
}
