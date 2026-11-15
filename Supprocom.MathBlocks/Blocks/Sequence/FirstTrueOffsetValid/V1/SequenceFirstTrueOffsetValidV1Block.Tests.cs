namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.first-true-offset-valid@1</c> operation contract.</summary>
public sealed class SequenceFirstTrueOffsetValidV1BlockTests
{
    /// <summary>Checks the <c>sequence.first-true-offset-valid@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.first-true-offset-valid@1");
}
