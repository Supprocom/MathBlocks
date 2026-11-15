namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.prefix-difference-over-offsets@1</c> operation contract.</summary>
public sealed class SequencePrefixDifferenceOverOffsetsV1BlockTests
{
    /// <summary>Checks the <c>sequence.prefix-difference-over-offsets@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.prefix-difference-over-offsets@1");
}
