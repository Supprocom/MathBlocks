namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.lag-valid@1</c> operation contract.</summary>
public sealed class SequenceLagValidV1BlockTests
{
    /// <summary>Checks the <c>sequence.lag-valid@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.lag-valid@1");
}
