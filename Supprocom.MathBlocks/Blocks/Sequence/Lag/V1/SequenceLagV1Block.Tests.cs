namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.lag@1</c> operation contract.</summary>
public sealed class SequenceLagV1BlockTests
{
    /// <summary>Checks the <c>sequence.lag@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.lag@1");
}
