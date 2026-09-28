namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex.create@1</c> operation contract.</summary>
public sealed class ComplexCreateV1BlockTests
{
    /// <summary>Checks the <c>complex.create@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex.create@1");
}
