namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.natural-logarithm@1</c> operation contract.</summary>
public sealed class ScalarNaturalLogarithmV1BlockTests
{
    /// <summary>Checks the <c>scalar.natural-logarithm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.natural-logarithm@1");
}
