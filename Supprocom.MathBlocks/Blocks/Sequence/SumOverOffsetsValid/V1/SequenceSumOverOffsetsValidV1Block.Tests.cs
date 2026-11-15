namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.sum-over-offsets-valid@1</c> operation contract.</summary>
public sealed class SequenceSumOverOffsetsValidV1BlockTests
{
    /// <summary>Checks the <c>sequence.sum-over-offsets-valid@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.sum-over-offsets-valid@1");
}
