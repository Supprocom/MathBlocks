namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.exponential@1</c> operation contract.</summary>
public sealed class ComplexExponentialV1BlockTests
{
    /// <summary>Checks the <c>complex.exponential@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.exponential@1");
}
