namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.l1-norm@1</c> operation contract.</summary>
public sealed class VectorL1NormV1BlockTests
{
    /// <summary>Checks the <c>vector.l1-norm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.l1-norm@1");
}
