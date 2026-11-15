namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.sum-over-offsets@1</c> operation contract.</summary>
public sealed class SequenceSumOverOffsetsV1BlockTests
{
    /// <summary>Checks the <c>sequence.sum-over-offsets@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.sum-over-offsets@1");
}
