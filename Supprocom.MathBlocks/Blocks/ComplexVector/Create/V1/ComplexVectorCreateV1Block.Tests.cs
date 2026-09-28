namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>complex-vector.create@1</c> operation contract.</summary>
public sealed class ComplexVectorCreateV1BlockTests
{
    /// <summary>Checks the <c>complex-vector.create@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("complex-vector.create@1");
}
