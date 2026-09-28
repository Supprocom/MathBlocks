namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.equal@1</c> operation contract.</summary>
public sealed class VectorEqualV1BlockTests
{
    /// <summary>Checks the <c>vector.equal@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.equal@1");
}
