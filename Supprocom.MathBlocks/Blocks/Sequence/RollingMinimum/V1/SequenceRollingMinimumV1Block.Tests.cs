namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.rolling-minimum@1</c> operation contract.</summary>
public sealed class SequenceRollingMinimumV1BlockTests
{
    /// <summary>Checks the <c>sequence.rolling-minimum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-minimum@1");
}
