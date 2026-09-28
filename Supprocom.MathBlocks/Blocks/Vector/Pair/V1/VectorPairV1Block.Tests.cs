namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>vector.pair@1</c> operation contract.</summary>
public sealed class VectorPairV1BlockTests
{
    /// <summary>Checks the <c>vector.pair@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("vector.pair@1");
}
