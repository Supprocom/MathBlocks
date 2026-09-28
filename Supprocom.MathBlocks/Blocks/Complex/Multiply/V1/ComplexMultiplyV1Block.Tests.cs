namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.multiply@1</c> operation contract.</summary>
public sealed class ComplexMultiplyV1BlockTests
{
    /// <summary>Checks the <c>complex.multiply@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.multiply@1");
}
