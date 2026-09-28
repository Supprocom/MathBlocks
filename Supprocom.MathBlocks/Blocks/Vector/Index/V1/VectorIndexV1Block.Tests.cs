namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.index@1</c> operation contract.</summary>
public sealed class VectorIndexV1BlockTests
{
    /// <summary>Checks the <c>vector.index@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.index@1");
}
