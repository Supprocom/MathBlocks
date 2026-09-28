namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.negate@1</c> operation contract.</summary>
public sealed class ComplexNegateV1BlockTests
{
    /// <summary>Checks the <c>complex.negate@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.negate@1");
}
