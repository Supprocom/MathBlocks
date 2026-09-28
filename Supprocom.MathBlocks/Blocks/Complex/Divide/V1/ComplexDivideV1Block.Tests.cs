namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.divide@1</c> operation contract.</summary>
public sealed class ComplexDivideV1BlockTests
{
    /// <summary>Checks the <c>complex.divide@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.divide@1");
}
