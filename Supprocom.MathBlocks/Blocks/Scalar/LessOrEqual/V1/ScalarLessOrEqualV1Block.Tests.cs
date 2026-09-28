namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.less-or-equal@1</c> operation contract.</summary>
public sealed class ScalarLessOrEqualV1BlockTests
{
    /// <summary>Checks the <c>scalar.less-or-equal@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.less-or-equal@1");
}
