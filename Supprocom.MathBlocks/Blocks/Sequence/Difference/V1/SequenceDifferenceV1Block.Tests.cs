namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.difference@1</c> operation contract.</summary>
public sealed class SequenceDifferenceV1BlockTests
{
    /// <summary>Checks the <c>sequence.difference@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.difference@1");
}
