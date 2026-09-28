namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.common-logarithm@1</c> operation contract.</summary>
public sealed class ScalarCommonLogarithmV1BlockTests
{
    /// <summary>Checks the <c>scalar.common-logarithm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.common-logarithm@1");
}
