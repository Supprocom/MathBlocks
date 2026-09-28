namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.rolling-quantile@1</c> operation contract.</summary>
public sealed class SequenceRollingQuantileV1BlockTests
{
    /// <summary>Checks the <c>sequence.rolling-quantile@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-quantile@1");
}
