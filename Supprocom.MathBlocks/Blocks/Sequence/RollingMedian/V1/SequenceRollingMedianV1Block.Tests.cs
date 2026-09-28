namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.rolling-median@1</c> operation contract.</summary>
public sealed class SequenceRollingMedianV1BlockTests
{
    /// <summary>Checks the <c>sequence.rolling-median@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-median@1");
}
