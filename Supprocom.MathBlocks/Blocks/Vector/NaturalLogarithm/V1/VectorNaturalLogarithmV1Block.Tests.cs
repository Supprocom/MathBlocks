namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.natural-logarithm@1</c> operation contract.</summary>
public sealed class VectorNaturalLogarithmV1BlockTests
{
    /// <summary>Checks the <c>vector.natural-logarithm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.natural-logarithm@1");
}
