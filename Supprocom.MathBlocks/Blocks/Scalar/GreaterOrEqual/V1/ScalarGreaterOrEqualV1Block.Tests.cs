namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.greater-or-equal@1</c> operation contract.</summary>
public sealed class ScalarGreaterOrEqualV1BlockTests
{
    /// <summary>Checks the <c>scalar.greater-or-equal@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.greater-or-equal@1");
}
