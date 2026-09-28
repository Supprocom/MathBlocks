namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>sequence.rolling-standard-deviation@1</c> operation contract.</summary>
public sealed class SequenceRollingStandardDeviationV1BlockTests
{
    /// <summary>Checks the <c>sequence.rolling-standard-deviation@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("sequence.rolling-standard-deviation@1");
}
