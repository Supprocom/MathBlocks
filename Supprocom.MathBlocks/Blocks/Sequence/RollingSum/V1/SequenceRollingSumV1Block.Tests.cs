namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.rolling-sum@1</c> operation contract.</summary>
public sealed class SequenceRollingSumV1BlockTests
{
    /// <summary>Checks the <c>sequence.rolling-sum@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-sum@1");
}
