namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.l2-norm@1</c> operation contract.</summary>
public sealed class VectorL2NormV1BlockTests
{
    /// <summary>Checks the <c>vector.l2-norm@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.l2-norm@1");
}
