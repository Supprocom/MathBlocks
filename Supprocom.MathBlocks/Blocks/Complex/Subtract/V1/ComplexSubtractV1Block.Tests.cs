namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.subtract@1</c> operation contract.</summary>
public sealed class ComplexSubtractV1BlockTests
{
    /// <summary>Checks the <c>complex.subtract@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.subtract@1");
}
