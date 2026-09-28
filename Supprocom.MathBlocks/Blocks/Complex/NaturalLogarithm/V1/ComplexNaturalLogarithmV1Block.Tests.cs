namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.natural-logarithm@1</c> operation contract.</summary>
public sealed class ComplexNaturalLogarithmV1BlockTests
{
    /// <summary>Checks the <c>complex.natural-logarithm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.natural-logarithm@1");
}
