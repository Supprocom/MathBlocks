namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.maximum-over-offsets@1</c> operation contract.</summary>
public sealed class SequenceMaximumOverOffsetsV1BlockTests
{
    /// <summary>Checks the <c>sequence.maximum-over-offsets@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.maximum-over-offsets@1");
}
