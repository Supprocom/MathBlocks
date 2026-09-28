namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.add@1</c> operation contract.</summary>
public sealed class ComplexAddV1BlockTests
{
    /// <summary>Checks the <c>complex.add@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.add@1");
}
