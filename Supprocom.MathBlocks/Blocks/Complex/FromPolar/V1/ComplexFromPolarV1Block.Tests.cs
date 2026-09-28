namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.from-polar@1</c> operation contract.</summary>
public sealed class ComplexFromPolarV1BlockTests
{
    /// <summary>Checks the <c>complex.from-polar@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.from-polar@1");
}
