namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.not-equal@1</c> operation contract.</summary>
public sealed class ScalarNotEqualV1BlockTests
{
    /// <summary>Checks the <c>scalar.not-equal@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.not-equal@1");
}
