namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.exponential-moving-average@1</c> operation contract.</summary>
public sealed class SequenceExponentialMovingAverageV1BlockTests
{
    /// <summary>Checks the <c>sequence.exponential-moving-average@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.exponential-moving-average@1");
}
