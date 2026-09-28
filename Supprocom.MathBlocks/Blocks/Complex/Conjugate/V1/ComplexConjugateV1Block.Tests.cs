namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.conjugate@1</c> operation contract.</summary>
public sealed class ComplexConjugateV1BlockTests
{
    /// <summary>Checks the <c>complex.conjugate@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.conjugate@1");
}
